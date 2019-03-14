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
    
    
    var dataController: DataController!
    var coordinates = CLLocationCoordinate2D()
    var pin: Pin!
    var URLArray = [URL]()
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        okButtonPressed(okButton)
        showMapItem()
        FlickrClient.sharedInstance().getPhotos(coordinates.latitude, coordinates.longitude) { [unowned self] (success, arrayOfURLs, error) in
            if success == true {
                guard let arrayOfURLs = arrayOfURLs else { return }
                for urls in arrayOfURLs {
                    self.URLArray.append(urls)
                    print(self.URLArray.count)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    func showMapItem() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        mapView.isUserInteractionEnabled = false
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
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    
    
    
    
    
    
    
    
    
}
