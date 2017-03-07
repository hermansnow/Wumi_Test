//
//  PostCategoryTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostCategoryTableViewController: PostFilterViewController {
    /// Post to be sent.
    var post = Post()
    /// Current login user to send this post.
    private lazy var currentUser = User.currentUser()
    /// Array of selected post category.
    private lazy var selectedCategories = [PostCategory]()
    /// CLLocation manager.
    private lazy var locationManager = CLLocationManager()
    /// Current location placemark.
    private var currentLocation: CLPlacemark?
    /// Flag to indicate whether application is locating current location.
    private var isLocating = false
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load current location
        self.locationManager.delegate = self
        self.getCurrentLocation()
    }
    
    // MARK: UI functions
    
    override func setupNavigationBar() {
        self.navigationItem.title = "New Post Options"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                 style: .Done,
                                                                 target: self,
                                                                 action: #selector(self.send))
    }
    
    // MARK: Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeueCell = tableView.dequeueReusableCellWithIdentifier("PostCategoryCell") {
            cell = dequeueCell
        }
        else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "PostCategoryCell")
        }
        
        switch indexPath.section {
        case 0:
            self.setupCategoryCell(cell, forRowAtIndexPath: indexPath)
        case 1:
            self.setupAreaCell(cell, forRowAtIndexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    /**
     Set up a post category filter cell.
     
     - Parameters:
     - cell: tableview cell to be set up.
     - forRowAtIndexPath: cell's index path.
     */
    override func setupCategoryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        super.setupCategoryCell(cell, forRowAtIndexPath: indexPath)
        
        guard let category = self.categories[safe: indexPath.row],
            checkButton = cell.accessoryView as? CheckButton else { return }
        
        if self.selectedCategories.contains(category) {
            checkButton.selected = true
        }
        else {
            checkButton.selected = false
        }
    }
    
    /**
     Set up an area category filter cell.
     
     - Parameters:
        - cell: tableview cell to be set up.
        - forRowAtIndexPath: cell's index path.
     */
    override func setupAreaCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        super.setupAreaCell(cell, forRowAtIndexPath: indexPath)
        
        guard let area = self.areas[safe: indexPath.row] else { return }
        
        if let currentLocation = self.currentLocation, location = currentLocation.location {
            let distance = location.distanceFromLocation(CLLocation(latitude: area.latitude, longitude: area.longitude)) / Constants.General.Value.MileToMeter
            if distance <= Constants.Post.nearbyPostMiles {
                cell.detailTextLabel?.text = "Nearby"
            }
        }
    }
    
    // MARK: Action
    
    override func selectCategory(sender: CheckButton) {
        guard let indexPath = sender.indexPath, category = self.categories[safe: indexPath.row] else { return }
        
        if sender.selected {
            self.selectedCategories.removeObject(category)
            sender.selected = false
        }
        else {
            self.selectedCategories.append(category)
            sender.selected = true
        }
    }
    
    /**
     Action when clicking send nagivation button.
     */
    func send() {
        self.post.author = self.currentUser
        self.post.categories = self.selectedCategories
        if let button = self.selectedAreaButton, indexPath = button.indexPath, area = self.areas[safe: indexPath.row] {
            self.post.area = area
        }
        else {
            self.post.area = nil
        }
        
        // Save post
        self.post.savePostInBackgroundWithBlock { (success, error) in
            guard success && error == nil else {
                ErrorHandler.log(error)
                return
            }
        }
        
        // Navigate back to home view controller
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Enable CLLocation Manager to get current device location.
     */
    private func getCurrentLocation() {
        if #available(iOS 8, *) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.startUpdatingLocation()
        }
    }
    
    /**
     Start updating current location.
     */
    private func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.isLocating = true
        
        // Set timer for timeout
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.stopUpdatingLocation()
        }
    }
    
    /**
     Stop updating current location.
     */
    private func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
        self.isLocating = false
        self.tableView.reloadData()
    }
}

// MARK: CLLocationManager delegate

extension PostCategoryTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation) { (result, error) -> Void in
            guard let locations = result where locations.count > 0 else {
                ErrorHandler.log(error?.localizedDescription)
                return
            }
            
            self.currentLocation = locations.first
            self.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        ErrorHandler.log(error.localizedDescription)
        self.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            self.startUpdatingLocation()
        default:
            break
        }
    }
}
