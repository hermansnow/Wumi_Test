//
//  ContactMapViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import BTNavigationDropdownMenu

class ContactMapViewController: DataLoadingViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    /// Array of contacts to be displayed on the map.
    var displayContacts = [User]()
    /// Search type. Check category list in ContactSearchType.
    var searchType: ContactSearchType = .All
    /// Current location of device.
    private var currentLocation: CLLocation?
    /// Radius for visible region.
    private var regionRadius: CLLocationDistance = 50000
    /// Flag to indicate whether we need to centerize user location
    private var centerUserLocation: Bool = true
    /// CLLocation manager.
    private var locationManager = CLLocationManager()
    /// Contact map manager.
    private var contactManager = ContactMapManager()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add dropdown list
        self.addDropdownList()
        
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
        self.centerUserLocation = true
        
        // Re-use existing cached map center
        if let centerLocation = MKMapView.getMapCenterCache() {
            self.mapView.centerMapOnLocation(centerLocation, WithRadius: self.regionRadius)
        }
        
        // Get current location
        self.getCurrentLocation()
    }
    
    /**
     Add a dropdown list includes filter categories to navigation title view.
     [Credential and reference](https://github.com/PhamBaTho/BTNavigationDropdownMenu).
     */
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All", "Favorites", "Graduation Year"]
        let optionSearchTypes: [ContactSearchType] = [.All, .Favorites, .Graduation]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = menuView
        
        // Set action closure
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = optionSearchTypes[safe: indexPath] else { return }
            
            if self.searchType != searchType {
                self.searchType = searchType
                self.updateSearchType() // Reload displaying contacts
            }
        }
    }
    
    // MARK: Help functions
    
    private func updateSearchType() {
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Load users
        User.loadUsers(type: self.searchType, forUser: self.currentUser) { (results, error) -> Void in
            // Dismiss loading indicator
            self.dismissLoadingIndicator()
            
            guard error == nil else { return }
            
            self.displayContacts = results
            self.loadContacts()
        }
    }
    
    /**
     Load all contacts needed to be displayed.
     */
    private func loadContacts() {
        let taskGroup = dispatch_group_create()
        
        var contactPoints = [ContactPoint]()
        
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Calculate a contact point's coordinates for each contact
        for contact in self.displayContacts {
            dispatch_group_enter(taskGroup)
            contact.location.calculateCoordinate { (result: Area?, error: NSError?) in
                guard let area = result where error == nil else {
                    dispatch_group_leave(taskGroup)
                    return
                }
                    
                let contactPoint = ContactPoint(Contact: contact)
                contactPoint.coordinate = CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude)
                
                contactPoints.append(contactPoint)
                dispatch_group_leave(taskGroup)
            }
        }
        
        // Cluster contact points into annotations
        dispatch_group_notify(taskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            self.contactManager.removeAllContactPoints()
            self.contactManager.addContactPoints(contactPoints)
            let annotations = self.contactManager.clusterContactPointsToAnnotions(withRect: self.mapView.visibleMapRect, zoomScale: scale)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.contactManager.showClusterAnnotations(annotations, onMapView: self.mapView)
                
                // Dismiss loading indicator
                self.dismissLoadingIndicator()
                
            })
        }
    }
}

// MARK: MKMapView delegate

extension ContactMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // Set user location as center location
        if let userLocation = userLocation.location where self.centerUserLocation {
            mapView.centerMapOnLocation(userLocation, WithRadius: self.regionRadius)
            self.centerUserLocation = false
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
            view.delegate = self
            
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
        if #available(iOS 8, *) {
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

// MARK: ContactAnnotationVie delegate

extension ContactMapViewController: ContactAnnotationViewDelegate {
    func tapCallout(view: ContactAnnotationView) {
        // Show a specific contact
        self.performSegueWithIdentifier("Show Contact", sender: view)
    }
}
