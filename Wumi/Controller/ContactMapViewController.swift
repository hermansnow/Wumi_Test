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
    
    var displayUsers = [User]()
    private var currentLocation: CLLocation?
    private var regionRadius: CLLocationDistance = 50000
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addMapView()
        
        self.loadContacts()
    }
    
    private func addMapView() {
        self.mapView.mapType = .Standard
        self.mapView.delegate = self
        self.locationManager.delegate = self
        if let centerLocation = MKMapView.getMapCenterCache() {
            self.mapView.centerMapOnLocation(centerLocation, WithRadius: self.regionRadius)
        }
        self.getCurrentLocation()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let annotationView = sender as? ContactAnnotationView,
                annotation = annotationView.annotation as? ContactPoint,
                selectedUser = annotation.user else { return }
            
            contactVC.selectedUserId = selectedUser.objectId
            contactVC.hidesBottomBarWhenPushed = true
        }
    }
    
    private func loadContacts() {
        for user in self.displayUsers {
            user.location.calculateCoordinate { (results: [CLPlacemark]?, error: NSError?) in
                guard let placemarks = results, placemark = placemarks.first, location = placemark.location else { return }
                
                let contactPoint = ContactPoint(User: user)
                contactPoint.coordinate = location.coordinate
                self.mapView.addAnnotation(contactPoint)
            }
        }
    }
}

extension ContactMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // Set user location as center location
        if let userLocation = userLocation.location {
            mapView.centerMapOnLocation(userLocation, WithRadius: self.regionRadius)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let contactPoint = annotation as? ContactPoint else { return nil }
        
        // Initialize annotation view
        let identifier = "contact"
        var view: ContactAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? ContactAnnotationView {
            dequeuedView.annotation = contactPoint
            view = dequeuedView
        }
        else {
            view = ContactAnnotationView(annotation: contactPoint, reuseIdentifier: identifier)
        }
        
        // Load user data
        if let user = contactPoint.user {
            user.loadAvatarThumbnail() { (avatarImage, imageError) -> Void in
                guard imageError == nil && avatarImage != nil else {
                    print("\(imageError)")
                    return
                }
                view.avatarImageView.image = avatarImage
            }
        }
        view.detail = contactPoint.detail
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegueWithIdentifier("Show Contact", sender: view)
    }
    
    func getCurrentLocation() {
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.mapView.showsUserLocation = true
        }
    }
}

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
