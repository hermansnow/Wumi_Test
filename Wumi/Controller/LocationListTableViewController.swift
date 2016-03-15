//
//  LocationListTableViewController.swift
//  Wumi
//
//  Created by Herman on 2/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationDelegate: LocationListDelegate?
    
    var countryList = [String]()
    var selectedLocation: Location?
    var locationManager = CLLocationManager()
    var isLocating = false
    var currentLocation: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadCountries()
    }
    
    override func viewWillAppear(animated: Bool) {
        getCurrentLocation()
        
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Current Location"
        case 1:
            return "All"
        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return countryList.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            if !CLLocationManager.locationServicesEnabled()
                || CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
                    let footerView = UITableViewHeaderFooterView()
                    
                    let warningLable = UILabel(frame: CGRect(x: 40, y: 10, width: tableView.frame.width - 80, height: tableView.sectionFooterHeight))
                    warningLable.font = UIFont.boldSystemFontOfSize(10)
                    warningLable.text = "Enable access for Wumi in \"Settings\" - \"Privacy\" - \"Location Service\" on your device"
                    warningLable.lineBreakMode = .ByWordWrapping
                    warningLable.textAlignment = .Center
                    warningLable.numberOfLines = 0
                    
                    footerView.addSubview(warningLable)
                    return footerView
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if !CLLocationManager.locationServicesEnabled()
                || CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
                    return 60
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
            
            if currentLocation == nil {
                if isLocating {
                    cell.textLabel!.text = "Location..."
                }
                else {
                    cell.textLabel!.text = "Unable to access your location"
                }
            }
            else {
                // TODO: unwrap check
                cell.textLabel!.text = (currentLocation?.country)! + ", " + (currentLocation?.locality)!
            }
        case 1:
            var countryName: String?
            cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
            
            countryName = countryList[safe: indexPath.row]
            cell.textLabel!.text = countryName
            
            // Add checkmark for selected country
            if countryName == selectedLocation?.country {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            selectedLocation = Location(Country: currentLocation?.country, City: currentLocation?.locality)
        case 1:
            selectedLocation = Location(Country: countryList[safe: indexPath.row], City: nil)
        default:
            break
        }
        
        if selectedLocation != nil {
            if locationDelegate != nil {
                locationDelegate?.finishLocationSelection(selectedLocation)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: CLLocationManager delegates
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation) { (result, error) -> Void in
            if let locations = result {
                if locations.count > 0 {
                    self.currentLocation = locations.first
                    self.stopUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error)")
        stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            startUpdatingLocation()
        default:
            break
        }
    }
    
    // Enable CLLocation Manager to get current device location
    private func getCurrentLocation() -> Void {
        locationManager.delegate = self
        
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        isLocating = true
        tableView.reloadData()
        
        // Set timer for timeout
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.stopUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLocating = false
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Country List functions
    private func loadCountries() -> Void {
        for countryCode in NSLocale.ISOCountryCodes() {
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                countryList.append(countryName)
            }
        }
        countryList.sortInPlace()
    }
}

protocol LocationListDelegate {
    func finishLocationSelection(location: Location?)
}

