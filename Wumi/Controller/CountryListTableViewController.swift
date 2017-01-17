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
    
    /// LocagtionList delegate.
    var locationDelegate: LocationListDelegate?
    
    /// Location manager.
    private lazy var locationManager = CLLocationManager()
    /// Flag to indicate whether we are locating current location or not.
    private var isLocating = false
    /// CLPlacemark for current location.
    private var currentLocation: CLPlacemark?
    
    /// Current selected location.
    var selectedLocation: Location?
    
    /// Country name and code map: [CountryName: CountryCode].
    lazy var countryList = [String: String]()
    /// Location map for countries: [CountryName: [StateName: [CityName]]].
    lazy var locations = [String: [String: [String]]]()
    
    // Add index collation
    
    /// Index collation.
    private lazy var collation = UILocalizedIndexedCollation.currentCollation()
    /// Index collation section array.
    private lazy var sections = [[String]]()
    /// Title string for each index collation sections.
    private lazy var sectionTitles = [String]()
    /// Title string for each indexes.
    private lazy var sectionIndexTitles = [String]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Set table view
        self.tableView.sectionIndexBackgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // Add delegates
        self.locationManager.delegate = self
        
        // Load country list
        self.loadLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCurrentLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let stateListTableViewController = segue.destinationViewController as? StateListTableViewController where segue.identifier == "Select State" {
            guard let index = self.tableView.indexPathForSelectedRow,
                sectionArray = self.sections[safe: index.section],
                countryName = sectionArray[safe: index.row],
                countryCode = self.countryList[countryName],
                countryData = self.locations[countryCode] else { return }
            
            stateListTableViewController.countryCode = countryCode
            stateListTableViewController.stateDict = countryData
            
            stateListTableViewController.locationDelegate = self.locationDelegate
            stateListTableViewController.selectedLocation = self.selectedLocation
        }
    }
    
    // MARK: UI functions
    
    /**
     Build and show section index for the table on right.
     
     - Parameters:
        - data: data to be displayed on table.
     */
    private func buildSectionIndex(data: [String]) {
        // Reset collation
        self.collation = UILocalizedIndexedCollation.currentCollation()
        
        // Initial a section array
        var sectionArrays: [[String]] = Array(count: self.collation.sectionTitles.count, repeatedValue: [String]())
        
        // Parse all display data to sections
        for item in data {
            let sectionIndex = collation.sectionForObject(item, collationStringSelector: #selector(NSObject.selfMethod))
            sectionArrays[sectionIndex].append(item)
        }
        
        // Add current location section
        self.sections.append([String]())
        self.sectionTitles.append("Current Location")
        
        // Build index
        for sectionIndex in 0..<sectionArrays.count {
            guard let section = sectionArrays[safe: sectionIndex] where section.count > 0 else { continue }
            
            self.sections.append(section)
            self.sectionTitles.append(self.collation.sectionTitles[sectionIndex])
            self.sectionIndexTitles.append(self.collation.sectionIndexTitles[sectionIndex])
        }
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
            // Show error message if location manager is not enabled or not authorized.
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
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("Current Location Cell", forIndexPath: indexPath)
            if self.currentLocation == nil {
                if isLocating {
                    cell.textLabel!.text = "Location..."
                }
                else {
                    cell.textLabel!.text = "Unable to access your location"
                }
            }
            else if let location = self.currentLocation {
                cell.textLabel!.text = "\(Location(CountryCode: location.ISOcountryCode, CountryName: location.country, State: location.administrativeArea, City: location.locality))"
            }
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
            guard let sectionArray = self.sections[safe: indexPath.section], country = sectionArray[safe: indexPath.row] else { break }
            
            cell.textLabel!.text = country
            
            // Add check image if it is current selected country
            if let countryCode = self.countryList[country], selectedLocation = self.selectedLocation where countryCode == selectedLocation.countryCode {
                cell.imageView?.image = UIImage(named: Constants.General.ImageName.Check)
            }
            
            cell.accessoryType = .DisclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            guard let location = self.currentLocation else { break }
            self.selectedLocation = Location(CountryCode: location.ISOcountryCode, State: location.administrativeArea, City: location.locality)
            
            if let location = selectedLocation, delegate = locationDelegate {
                delegate.finishLocationSelection(location)
            }
            
            self.navigationController?.popViewControllerAnimated(true)
            break
        default:
            break
        }
    }
    
    // MARK: Help functions
    
    /**
     Load location data from plist file "country_state_city".
     */
    private func loadLocations() -> Void {
        guard let plistPath = NSBundle.mainBundle().pathForResource("country_state_city", ofType: "plist"),
            data = NSDictionary(contentsOfFile: plistPath) as? [String: [String: [String]]] else { return }
        
        self.locations = data
        let countryCodes = Array(self.locations.keys)
        
        // Compose country list based on local display name
        for countryCode in countryCodes {
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                self.countryList[countryName] = countryCode
            }
        }
        var countries = Array(self.countryList.keys)
        countries.sortInPlace()
        
        self.buildSectionIndex(countries)
    }
}

// MARK: CLLocationManager delegate

extension LocationListTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation) { (result, error) -> Void in
            guard let locations = result where locations.count > 0 else {
                ErrorHandler.log("\(error)")
                return
            }
            
            self.currentLocation = locations.first
            self.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        ErrorHandler.log("\(error)")
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
    
    /**
     Enable CLLocation Manager to get current device location.
     */
    private func getCurrentLocation() {
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            startUpdatingLocation()
        }
    }
    
    /**
     Start updating current location.
     */
    private func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.isLocating = true
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        
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
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
}

// MARK: Custome delegate

protocol LocationListDelegate {
    func finishLocationSelection(location: Location?)
}

