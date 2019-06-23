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

final class TravelLocationsMapVC: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var loadedSavedRegion = false
    var pins: [Pin] = []
    var pinObject: Pin!
    var photoImagePool: [Photo] = []
    var mapCoordinates = CLLocationCoordinate2D()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        dataController = appDelegate.dataController
        mapView.delegate = self
        deletePinsLabel.isHidden = true
        
        addGestureRecognizer()
        setupFetchResultsController()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultsController()
    }
    
    // udacity forums
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        savedMapRegion()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
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
    
    func savedMapRegion() {
        if !loadedSavedRegion {
            if let savedRegion = UserDefaults.standard.object(forKey: "savedMapRegion") as? [String: Double] {
                let center = CLLocationCoordinate2D(latitude: savedRegion["mapRegionCenterLat"] ?? 0.0, longitude: savedRegion["mapRegionCenterLon"] ?? 0.0)
                let span = MKCoordinateSpan(latitudeDelta: savedRegion["mapRegionSpanLatDelta"] ?? 0.0, longitudeDelta: savedRegion["mapRegionSpanLonDelta"] ?? 0.0)
                mapView.region = MKCoordinateRegion(center: center, span: span)
            }
            loadedSavedRegion = true
        }
    }
    
    
    func addGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pressedLocation))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.5
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.title == "Edit" {
            editingMode()
        } else {
            notInEditingMode()
        }
    }
    
    func editingMode() {
        deletePinsLabel.isHidden = false
        editButton.title = "Done"
        mapView.frame.origin.y -= deletePinsLabel.frame.height
    }
    
    func notInEditingMode() {
        deletePinsLabel.isHidden = true
        editButton.title = "Edit"
        mapView.frame.origin.y += deletePinsLabel.frame.height
        
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
            mapCoordinates = location
            
            mapView.addAnnotation(annotation)
            addPin(location: location)
        }
    }
    
    func addPin(location: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = location.longitude
        pin.latitude = location.latitude
        pin.creationDate = Date()
        pinObject = pin
        
        guard let _ = try? dataController.viewContext.save() else { return }
        
    }
    
    // udacity forums and stackoverflow
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is due to user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if (recognizer.state == .began || recognizer.state == .ended) {
                    return true
                }
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? PhotoAlbumVC else { fatalError("unable to segue to PhotoAlbumVC") }
       
        destinationVC.coordinates = mapCoordinates
        destinationVC.dataController = dataController
        destinationVC.pin = pinObject

}

}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.
