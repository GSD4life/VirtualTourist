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

class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    var dataController: DataController!
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
        loadImagesIfNoneAvailable()
        setupFetchResultsController()
        
        photos = fetchedResultsController.fetchedObjects ?? []
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
        //let predicate = NSPredicate(format: "pin == %@", pin) - throws an error
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
        
        if photos.isEmpty {
            getPhotoURLs()
        }
    }
    
    fileprivate func getPhotoURLs() {
        FlickrClient.sharedInstance().getPhotos(coordinates.latitude, coordinates.longitude) { [unowned self] (success, arrayOfURLs, error) in
            if success == true {
                guard let arrayOfURLs = arrayOfURLs else { return }
                for photoUrls in arrayOfURLs  {
                    
                    let flickrPhoto = Photo(context: self.dataController.viewContext)
                    self.managedObjectId = flickrPhoto.objectID
                    flickrPhoto.name = photoUrls.absoluteString
                    flickrPhoto.creationDate = Date()
                    flickrPhoto.imageURL = photoUrls.absoluteString
                    flickrPhoto.pin = self.pin 
                    self.photos.append(flickrPhoto)
                    if self.dataController.viewContext.hasChanges {
                        performUIUpdatesOnMain {
                            guard let _ = try? self.dataController.viewContext.save() else {
                                print("unable to save")
                                return
                            }
                            self.collectionView.reloadData()
                        }
                    }
                    self.URLArray.append(photoUrls)
                    print(self.URLArray.count)
                }
            } else {
                if success == false {
                    guard let error = error else { return }
                    self.getPhotosURLAlertView(error.localizedDescription)
                    
                }
            }
        }
    }
    
    fileprivate func getPhotosURLAlertView(_ error: String?) {
        let alertViewController = UIAlertController(title: "Download Error", message: "The request most likely timed out.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }
    
    
    func showMapItem() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        mapView.isUserInteractionEnabled = false
    }
    
    
    @IBAction func newCollectionButtonPressed(_ sender: UIBarButtonItem) {
        
        if var fetchedPhotoArray = fetchedResultsController.fetchedObjects {
            fetchedPhotoArray.forEach { (photo) in
                photos.append(photo)
            }
            
            if fetchedPhotoArray.isEmpty {
                newCollectionButton.isEnabled = false
            } else {
                fetchedPhotoArray = []
                getPhotoURLs()
                newCollectionButton.isEnabled = true
                
            }
        }
    }

    
    @IBAction func okButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        let reuseId = "mapPin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
            
        }
            
        else {
            pinView!.annotation = annotation
        }
        return pinView!
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)
            as! PhotoCollectionViewCell
        
        
        let cellPhotoImage = fetchedResultsController.object(at: indexPath)
        
        guard let cellURL = cellPhotoImage.imageURL else { return cell }
        assert(cellURL == cellPhotoImage.imageURL, "CellURL error, line 209")
        
        guard let url = URL(string: cellURL) else { return cell }
        assert(url == URL(string: cellURL), "Url error within CellForItemAt, line 211")
        
        performUIUpdatesOnMain {
            cell.activityViewIndicator.startAnimating()
            cell.activityViewIndicator.hidesWhenStopped = true
        }

        FlickrClient.sharedInstance().downloadImages(url) { [unowned self] (data, error) in
            guard (error == nil) else { return }
            assert(error == nil, "FlickrClient download images issue, line 220")
            if let data = data {
                performUIUpdatesOnMain {
                    cellPhotoImage.image = data
                    guard let cellImage = cellPhotoImage.image else { return }
                    cellPhotoImage.pin = self.pin
                    guard let _ = try? self.dataController.viewContext.save() else { return }
                    cell.virtualTouristImageView.image = UIImage(data: cellImage)
                    cell.setNeedsLayout()
                    cell.activityViewIndicator.stopAnimating()
                }
            }
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAT function reached")
        
        let flickrPhoto = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(flickrPhoto)
        
    
}
    
    
    
    
    
    
    
    
    
    
}
