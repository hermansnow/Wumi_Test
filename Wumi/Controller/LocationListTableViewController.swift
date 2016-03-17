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

class LocationListTableViewController: UITableViewController {
    
    var locationDelegate: LocationListDelegate?
    
    lazy var countryList = [String]()
    var selectedLocation: Location?
    lazy var locationManager = CLLocationManager()
    var isLocating = false
    var currentLocation: CLPlacemark?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add delegates
        self.locationManager.delegate = self
        
        // Load country list
        loadCountries()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCurrentLocation()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            if !CLLocationManager.locationServicesEnabled() ||
                CLLocationManager.authorizationStatus() == .Denied ||
                CLLocationManager.authorizationStatus() == .Restricted {
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
            return nil
        
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if !CLLocationManager.locationServicesEnabled() ||
                CLLocationManager.authorizationStatus() == .Denied ||
                CLLocationManager.authorizationStatus() == .Restricted {
                    return 60
            }
            return 0
        
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            if self.currentLocation == nil {
                if isLocating {
                    cell.textLabel!.text = "Location..."
                }
                else {
                    cell.textLabel!.text = "Unable to access your location"
                }
            }
            else if let location = self.currentLocation {
                cell.textLabel!.text = "\(Location(Country: location.country, City: location.locality))"
            }
        case 1:
            var countryName: String?
            
            countryName = self.countryList[safe: indexPath.row]
            cell.textLabel!.text = countryName
            
            // Add checkmark for selected country
            if let location = self.selectedLocation where location.country == countryName {
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
            guard let location = self.currentLocation else { break }
            self.selectedLocation = Location(Country: location.country, City: location.locality)
        case 1:
            self.selectedLocation = Location(Country: countryList[safe: indexPath.row], City: nil)
        default:
            break
        }
        
        if let location = selectedLocation, delegate = locationDelegate {
            delegate.finishLocationSelection(location)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Help functions
    
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
    
    private func loadCountries() -> Void {
        for countryCode in NSLocale.ISOCountryCodes() {
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                self.countryList.append(countryName)
            }
        }
        self.countryList.sortInPlace()
    }
}

// MARK: CLLocationManager delegate

extension LocationListTableViewController: CLLocationManagerDelegate {
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

// MARK: Custome delegate

protocol LocationListDelegate {
    func finishLocationSelection(location: Location?)
}

