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
    
    // Add index collation
    lazy var collation = UILocalizedIndexedCollation.currentCollation()
    lazy var sections = [[String]]()
    lazy var sectionTitles = [String]()
    lazy var sectionIndexTitles = [String]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.tableView.sectionIndexBackgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // Add delegates
        self.locationManager.delegate = self
        
        // Load country list
        self.loadCountries()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCurrentLocation()
    }

    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            guard let sectionArray = self.sections[safe: section] else { return 0 }
            return sectionArray.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String] {
        return self.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index + 1
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
        default:
            guard let sectionArray = self.sections[safe: indexPath.section], country = sectionArray[safe: indexPath.row] else { break }
            
            cell.textLabel!.text = country
            
            // Add checkmark for selected country
            if let location = self.selectedLocation where location.country == country {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            guard let location = self.currentLocation else { break }
            self.selectedLocation = Location(Country: location.country, City: location.locality)
        default:
            guard let sectionArray = self.sections[safe: indexPath.section], country = sectionArray[safe: indexPath.row] else { break }
            self.selectedLocation = Location(Country: country, City: nil)
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
        var countryList = [String]()
        
        for countryCode in NSLocale.ISOCountryCodes() {
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                countryList.append(countryName)
            }
        }
        countryList.sortInPlace()
        
        self.buildSectionIndex(countryList)
    }
    
    private func buildSectionIndex(data: [String]) {
        // Reser collasion
        self.collation = UILocalizedIndexedCollation.currentCollation()
        
        var sectionArrays: [[String]] = Array(count: self.collation.sectionTitles.count, repeatedValue: [String]())
        
        for country in data {
            let sectionIndex = collation.sectionForObject(country, collationStringSelector: Selector("self"))
            sectionArrays[sectionIndex].append(country)
        }
        
        // Add current location section
        self.sections.append([String]())
        self.sectionTitles.append("Current Location")
        
        for sectionIndex in 0..<sectionArrays.count {
            guard let section = sectionArrays[safe: sectionIndex] where section.count > 0 else { continue }
            
            self.sections.append(section)
            self.sectionTitles.append(self.collation.sectionTitles[sectionIndex])
            self.sectionIndexTitles.append(self.collation.sectionIndexTitles[sectionIndex])
        }
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

