//
//  TravelLocationsMapVC.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/6/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var loadedSavedRegion = false
    var pin: [Pin]?
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
           pin = result
           print(result)
        }

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch request could not be performed: \(error.localizedDescription)")
        }
        loadPins()
}
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        deletePinsLabel.isHidden = true
        
        addGestureRecognizer()
        
        
        //setupFetchResultsController()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    // udacity forums
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loadedSavedRegion {
            if let savedRegion = UserDefaults.standard.object(forKey: "savedMapRegion") as? [String: Double] {
                let center = CLLocationCoordinate2D(latitude: savedRegion["mapRegionCenterLat"] ?? 0.0, longitude: savedRegion["mapRegionCenterLon"] ?? 0.0)
                let span = MKCoordinateSpan(latitudeDelta: savedRegion["mapRegionSpanLatDelta"] ?? 0.0, longitudeDelta: savedRegion["mapRegionSpanLonDelta"] ?? 0.0)
                mapView.region = MKCoordinateRegion(center: center, span: span)
            }
            loadedSavedRegion = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func addGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pressedLocation))
        gestureRecognizer.minimumPressDuration = 0.5
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editButton.title = "Done"
        deletePinsLabel.isHidden = false
        
        
        
    }
    
    fileprivate func loadPins() {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            var annotations = [MKPointAnnotation]()
            
            for pinObjects in fetchedObjects {
                let latitude = CLLocationDegrees(pinObjects.latitude)
                let longitude = CLLocationDegrees(pinObjects.longitude)
                
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                
                
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }
        
    }
    
    
    
    @objc func pressedLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
        let areaPressed = sender.location(in: mapView)
        let location = mapView.convert(areaPressed, toCoordinateFrom: mapView)
            
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Ninpo"
       
        
        mapView.addAnnotation(annotation)
       }
    }
    
    
    
    // udacity forums and stackoverflow
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is due to user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if (recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended) {
                    return true
                }
            }
        }
        return false
    }
    
    // udacity forums
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            let regionToSave = [
                "mapRegionCenterLat": mapView.region.center.latitude,
                "mapRegionCenterLon": mapView.region.center.longitude,
                "mapRegionSpanLatDelta": mapView.region.span.latitudeDelta,
                "mapRegionSpanLonDelta": mapView.region.span.longitudeDelta
            ]
            UserDefaults.standard.set(regionToSave, forKey: "savedMapRegion")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let _ = performSegue(withIdentifier: "PhotoAlbumVC", sender: self)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
