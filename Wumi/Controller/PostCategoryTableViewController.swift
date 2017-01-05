//
//  PostCategoryTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostCategoryTableViewController: DataLoadingTableViewController {
    
    lazy var sendButton = UIBarButtonItem()
    
    var post = Post()
    lazy var currentUser = User.currentUser()
    lazy var categories = [PostCategory]()
    lazy var areas = [Area]()
    lazy var selectedCategories = [PostCategory]()
    var selectedAreaButton: UIButton?
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLPlacemark?
    var isLocating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        self.sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: #selector(sendPost(_:)))
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        // Load categories
        self.loadPostCategories()
        
        // Load areas
        self.loadSearchAreas()
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.categories.count
        case 1:
            return self.areas.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Category"
        case 1:
            return "Area"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCategoryCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            self.categoryCell(cell, forRowAtIndexPath: indexPath)
        case 1:
            self.areaCell(cell, forRowAtIndexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    private func categoryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let category = self.categories[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = category.name
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Check),
                             forState: .Selected)
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Uncheck),
                             forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(selectCategory(_:)), forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    private func areaCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if self.currentLocation == nil {
                if isLocating {
                    cell.textLabel!.text = "Location..."
                }
                else {
                    cell.textLabel!.text = "Unable to access your location"
                }
            }
            else if let location = self.currentLocation, city = location.locality {
                cell.textLabel!.text = "Current location: " + city
            }
        }
        else if let area = self.areas[safe: indexPath.row - 1] {
            cell.textLabel!.text = area.name
        }
        else {
            return
        }
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Check),
                             forState: .Selected)
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Uncheck),
                             forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(selectArea(_:)), forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    // MARK: Action
    
    func selectCategory(sender: UIButton) {
        guard let category = self.categories[safe: sender.tag] else { return }
        
        if sender.selected {
            self.selectedCategories.removeObject(category)
            sender.selected = false
        }
        else {
            self.selectedCategories.append(category)
            sender.selected = true
        }
    }
    
    func selectArea(sender: UIButton) {
        if !sender.selected {
            if let button = self.selectedAreaButton {
                button.selected = false
            }
            sender.selected = true
            self.selectedAreaButton = sender
        }
        else {
            sender.selected = false
            self.selectedAreaButton = nil
        }
    }
    
    func sendPost(sender: AnyObject) {
        post.author = self.currentUser
        post.categories = self.selectedCategories
        
        if let currentLocationMark = self.currentLocation, currentLocation = currentLocationMark.location, name = currentLocationMark.name {
            
            let latitude = Double(currentLocation.coordinate.latitude)
            let longitude = Double(currentLocation.coordinate.longitude)
            post.area = Area(name: name, latitude: latitude, longitude: longitude)
        }
        
        self.showLoadingIndicator()
        post.saveInBackgroundWithBlock { (success, error) in
            self.dismissLoadingIndicator()
            guard success && error == nil else {
                print("\(error)")
                return
            }
        }
        
        // Navigate back to home view controller
        if let postTVC = self.navigationController?.viewControllers.filter({ $0 is HomeViewController }).first {
            self.navigationController?.popToViewController(postTVC, animated: true)
        }
    }

    // MARK: Help function
    private func loadPostCategories() {
        PostCategory.loadCategories { (results, error) -> Void in
            guard let categories = results as? [PostCategory] where error == nil && categories.count > 0 else { return }
            
            self.categories = categories
            
            self.tableView.reloadData()
        }
    }
    
    private func loadSearchAreas() {
        self.locationManager.delegate = self
        self.getCurrentLocation()
        
        guard let plistPath = NSBundle.mainBundle().pathForResource("search_areas", ofType: "plist"),
            areaDict = NSDictionary.init(contentsOfFile: plistPath) as? [String: [String: Double]] else { return }
        
        for area in areaDict {
            if let latitude = area.1["Latitude"], longitude = area.1["Longitude"] {
                self.areas.append(Area(name: area.0, latitude: latitude, longitude: longitude))
            }
        }
    }
    
    // Enable CLLocation Manager to get current device location
    private func getCurrentLocation() {
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.isLocating = true
        tableView.reloadData()
        
        // Set timer for timeout
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.stopUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
        self.isLocating = false
        tableView.reloadData()
    }
}

// MARK: CLLocationManager delegate

extension PostCategoryTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation) { (result, error) -> Void in
            guard let locations = result where locations.count > 0 else {
                print("\(error)")
                return
            }
            
            self.currentLocation = locations.first
            self.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error)")
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
