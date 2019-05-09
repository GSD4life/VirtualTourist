//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/13/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var dataController: DataController!
    var flickrPhotoId: NSManagedObjectID!
    var coordinates = CLLocationCoordinate2D()
    var pin: Pin!
    var photos: [Photo] = []
    var photoURL: URL?
    var dataForPhotos = Data()
    var images = UIImage()
    var URLArray = [URL]()
    var managedObjectId: NSManagedObjectID?
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        flowLayoutSetup()
        okButtonPressed(okButton)
        collectionView.dataSource = self
        collectionView.delegate = self
        showMapItem()
        setupFetchResultsController()
        loadImagesIfNoneAvailable()
        updateBottomButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadImagesIfNoneAvailable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    
    fileprivate func flowLayoutSetup() {
        let space: CGFloat = 0
        let lineSpacing: CGFloat = 1
        let dimension = (view.frame.size.width)/3
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "location", ascending: true)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            photos = result
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch request could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func loadImagesIfNoneAvailable() {
        
        if let pinPhotos = pin.photos {
            if pinPhotos.count <= 0 {
                newCollectionButton.isEnabled = false
                //noImagesLabelSetup()
                getPhotoURLs()
            }
            
        }
    }
    
    fileprivate func getPhotoURLs() {
        
        
        FlickrClient.sharedInstance().getPhotos(self.pin.latitude, self.pin.longitude) { [weak self] (success, arrayOfURLs, error) in
            if success == true {
                guard let arrayOfURLs = arrayOfURLs else { return }
                
                performUIUpdatesOnMain {
                    
                    for photoUrls in arrayOfURLs  {
                        
                        
                        let flickrPhoto = Photo(context: (self?.dataController.viewContext)!)
                        self?.managedObjectId = flickrPhoto.objectID
                        flickrPhoto.name = photoUrls.absoluteString
                        flickrPhoto.creationDate = Date()
                        flickrPhoto.imageURL = photoUrls.absoluteString
                        flickrPhoto.pin = self?.pin
                        
                        self?.flickrPhotoId = flickrPhoto.objectID
                        
                        self?.photos.append(flickrPhoto)
                        
                        
                        self?.saveChanges()
                        
                        self?.URLArray.append(photoUrls)
                        print(self?.URLArray.count ?? 0)
                    }
                    //self?.collectionView.reloadData()
                }
                
            } else {
                if success == false {
                    guard let error = error else { return }
                    self?.getPhotosURLAlertView(error.localizedDescription)
                    
                }
            }
        }
    }
    
    fileprivate func getPhotosURLAlertView(_ error: String?) {
        let alertViewController = UIAlertController(title: "Download Error", message: "The request most likely timed out.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }
    
    func saveChanges() {
        if dataController.viewContext.hasChanges {
            guard let _ = try? dataController.viewContext.save() else {
                print("unable to save")
                return }
        }
    }
    
    func emptyArrays() {
        URLArray = []
        photos = []
    }
    
    func showMapItem() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        mapView.isUserInteractionEnabled = false
    }
    
    
    @IBAction func newCollectionButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let pinImages = pin.photos else { return }
        if pinImages.count <= 0 {
            deleteAllPhotos()
        } else {
            emptyArrays()
            deleteSelectedPhoto()
            getPhotoURLs()
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func noImagesLabelSetup() {
        performUIUpdatesOnMain { [weak self] in
            
            guard let pinPhotos = self?.pin.photos?.count else { return }
            
            if pinPhotos == 0 {
                self?.noImagesLabel.isHidden = false
                self?.noImagesLabel.textAlignment = .center
                self?.noImagesLabel.text = "This pin has no images"
                
            } else {
                self?.noImagesLabel.isHidden = true
            }
        }
        
    }
    
    func deleteAllPhotos() {
        
        if let fetchedPhotoArray = fetchedResultsController.fetchedObjects {
            
            fetchedPhotoArray.forEach { (photo) in
                dataController.viewContext.delete(photo)
                saveChanges()
            }
            
            
        }
    }
    
    func deleteSelectedPhoto() {
        var photosToDelete = fetchedResultsController.fetchedObjects ?? []
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.object(at: indexPath) )
        }
        
        for photo in photosToDelete {
            dataController.viewContext.delete(photo)
            saveChanges()
        }
        
        selectedIndexes = [IndexPath]()
    }
    
    func updateBottomButton() {
        
        if selectedIndexes.count > 0 {
            newCollectionButton.title = "Remove Selected Picture"
        } else {
            newCollectionButton.title = "New Collection"
        }
    }
    
    func configureCell(_ cell: PhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        // let photo = fetchedResultsController.object(at: indexPath)
        
        if let _ = selectedIndexes.firstIndex(of: indexPath) {
            cell.backgroundColor = .white
            cell.virtualTouristImageView.alpha = 0.5
        } else {
            cell.backgroundColor = .white
            cell.virtualTouristImageView.alpha = 1.0
        }
    }
    
}
