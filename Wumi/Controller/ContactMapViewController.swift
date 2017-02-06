//
//  ContactMapViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit

class ContactMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    /// Array of contacts to be displayed on the map.
    var displayContacts = [User]()
    /// Current location of device.
    private var currentLocation: CLLocation?
    /// Radius for visible region.
    private var regionRadius: CLLocationDistance = 50000
    /// CLLocation manager.
    private var locationManager = CLLocationManager()
    /// Contact map manager.
    private var contactManager = ContactMapManager()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add MKMapView instance
        self.setMapView()
        
        // Load contacts
        self.loadContacts()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let annotationView = sender as? ContactAnnotationView,
                annotation = annotationView.annotation as? ContactPoint,
                selectedContact = annotation.contact else { return }
            
            contactVC.contact = selectedContact
            contactVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: UI Functions
    
    /**
     Initialize the map view
     */
    private func setMapView() {
        self.mapView.mapType = .Standard
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        // Re-use existing cached map center
        if let centerLocation = MKMapView.getMapCenterCache() {
            self.mapView.centerMapOnLocation(centerLocation, WithRadius: self.regionRadius)
        }
        
        // Get current location
        self.getCurrentLocation()
    }
    
    // MARK: Help functions
    
    /**
     Load all contacts needed to be displayed.
     */
    private func loadContacts() {
        let taskGroup = dispatch_group_create()
        
        var contactPoints = [ContactPoint]()
        
        // Calculate a contact point's coordinates for each contact
        for contact in self.displayContacts {
            dispatch_group_enter(taskGroup)
            contact.location.calculateCoordinate { (results: [CLPlacemark]?, error: NSError?) in
                guard let placemarks = results, placemark = placemarks.first, location = placemark.location else {
                    dispatch_group_leave(taskGroup)
                    return
                }
                    
                let contactPoint = ContactPoint(Contact: contact)
                contactPoint.coordinate = location.coordinate
                
                contactPoints.append(contactPoint)
                dispatch_group_leave(taskGroup)
            }
        }
        
        // Cluster contact points into annotations
        dispatch_group_notify(taskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            self.contactManager.addContactPoints(contactPoints)
            let annotations = self.contactManager.clusterContactPointsToAnnotions(withRect: self.mapView.visibleMapRect, zoomScale: scale)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.contactManager.showClusterAnnotations(annotations, onMapView: self.mapView)
            })
        }
    }
}

// MARK: MKMapView delegate

extension ContactMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // Set user location as center location
        if let userLocation = userLocation.location {
            mapView.centerMapOnLocation(userLocation, WithRadius: self.regionRadius)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // Show a contact point annotation view
        if let contactPoint = annotation as? ContactPoint {
            let identifier = "contact"
            var view: ContactAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? ContactAnnotationView {
                dequeuedView.annotation = contactPoint
                view = dequeuedView
            }
            else {
                view = ContactAnnotationView(annotation: contactPoint, reuseIdentifier: identifier)
            }
            
            // Load contact data
            if let contact = contactPoint.contact {
                contact.loadAvatarThumbnail() { (avatarImage, imageError) -> Void in
                    guard imageError == nil && avatarImage != nil else {
                        ErrorHandler.log("\(imageError)")
                        return
                    }
                    view.avatarImage = avatarImage
                }
            }
            view.detail = contactPoint.detail
            
            return view
        }
        // Show a clustered contacts annotation view
        else if let clusteredContacts = annotation as? ClusteredContacts {
            let identifier = "cluster"
            var view: ClusteredContactsAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? ClusteredContactsAnnotationView {
                dequeuedView.annotation = clusteredContacts
                view = dequeuedView
            }
            else {
                view = ClusteredContactsAnnotationView(annotation: clusteredContacts, reuseIdentifier: identifier)
            }
            
            // Load cluster data
            view.clusterCount = clusteredContacts.contactPoints.count
            
            return view
        }
        else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Show a specific contact
        self.performSegueWithIdentifier("Show Contact", sender: view)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Re-cluster contact points when visible region is changed
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            let annotations = self.contactManager.clusterContactPointsToAnnotions(withRect: self.mapView.visibleMapRect, zoomScale: scale)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.contactManager.showClusterAnnotations(annotations, onMapView: self.mapView)
            })
        }
    }
    
    /**
     Get current device's location and show it on map as user location.
     */
    private func getCurrentLocation() {
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.mapView.showsUserLocation = true
        }
    }
}

// MARK: CLLocationManager delegate

extension ContactMapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            self.mapView.showsUserLocation = true
        default:
            break
        }
    }
}
