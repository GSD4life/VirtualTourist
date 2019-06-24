//
//  MapViewDelegate.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 5/9/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import MapKit

extension TravelLocationsMapVC: MKMapViewDelegate {
    
    // udacity forums
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            let regionToSave = [
                "mapRegionCenterLat": mapView.region.center.latitude,
                "mapRegionCenterLon": mapView.region.center.longitude,
                "mapRegionSpanLatDelta": mapView.region.span.latitudeDelta,
                "mapRegionSpanLonDelta": mapView.region.span.longitudeDelta
            ]
            
            let _ = UserDefaults.standard.set(regionToSave, forKey: "savedMapRegion")
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        guard let pinImage = view.annotation else { return }
        
        guard let _ = try? fetchedResultsController.performFetch() else {
            print("Not able to fetch pin objects - line 34 of mapView delegate")
            return }
        
        let fetchedPinObjects = fetchedResultsController.fetchedObjects ?? []
        
        fetchedPinObjects.forEach { (pin) in
            if pin.latitude == pinImage.coordinate.latitude && pin.longitude == pinImage.coordinate.longitude {
                pinObject = pin
            }
        }
        
        if editButton.title == "Done" {
            mapView.removeAnnotation(pinImage)
        } else {
            let _ = performSegue(withIdentifier: "PhotoAlbumVC", sender: self)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.
