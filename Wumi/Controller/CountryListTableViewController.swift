//
//  CountryListTableViewController.swift
//  Wumi
//
//  Created by Herman on 2/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CountryListTableViewController: LocationListTableViewController {
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
    /// Location dictionary for countries: [CountryName: [StateName: [CityName]]].
    lazy var locations = [String: [String: [String]]]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
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
            
            stateListTableViewController.stateDict = countryData
            stateListTableViewController.selectedLocation = self.selectedLocation
            stateListTableViewController.locationDelegate = self.locationDelegate
        }
    }
    
    // MARK: UI functions
    
    /**
     Build and show section index for the table on right.
     
     - Parameters:
        - data: data to be displayed on table.
     */
    override func buildSectionIndex(data: [String]) {
        // Add current location section
        self.sections.append([String]())
        self.sectionTitles.append("Current Location")
        
        super.buildSectionIndex(data)
    }

    // MARK: Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            guard let sectionArray = self.sections[safe: section] else { return 0 }
            return sectionArray.count
        }
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
                    let warningLable = UILabel()
                    warningLable.backgroundColor = Constants.General.Color.LightBackgroundColor
                    warningLable.font = Constants.General.Font.ErrorFont
                    warningLable.text = "Enable access for Wumi in \"Settings\" - \"Privacy\" - \"Location Service\" on your device"
                    warningLable.lineBreakMode = .ByWordWrapping
                    warningLable.textAlignment = .Center
                    warningLable.numberOfLines = 0
                
                    return warningLable
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
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationTableViewCell else {
                return UITableViewCell()
            }
            
            cell.reset()
            
            if self.currentLocation == nil {
                if isLocating {
                    cell.title = "Location..."
                }
                else {
                    cell.title = "Unable to access your location"
                }
                cell.selectionStyle = .None
            }
            else if let locationPlacemark = self.currentLocation {
                let location = Location(CountryCode: locationPlacemark.ISOcountryCode,
                                        CountryName: locationPlacemark.country,
                                        State: locationPlacemark.administrativeArea,
                                        City: locationPlacemark.locality)
                
                cell.title = location.description
                if let selectedLocation = self.selectedLocation where selectedLocation == location {
                    cell.detail = "Selected"
                }
            }
            cell.accessoryType = .None
            
            return  cell
            
        default:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationTableViewCell,
                sectionArray = self.sections[safe: indexPath.section], country = sectionArray[safe: indexPath.row] else { break }
            
            cell.reset()
            
            cell.title = country
            
            // Add check image if it is current selected country
            if let countryCode = self.countryList[country], selectedLocation = self.selectedLocation where countryCode == selectedLocation.countryCode {
                cell.detail = "Selected"
            }
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
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
            guard let sectionArray = self.sections[safe: indexPath.section],
                countryName = sectionArray[safe: indexPath.row],
                countryCode = self.countryList[countryName] else { return }
            
            // Update selected location
            if let _ = self.selectedLocation {
                self.selectedLocation!.countryCode = countryCode
                self.selectedLocation!.countryName = countryName
            }
            else {
                self.selectedLocation = Location(CountryCode: countryCode,
                                                 CountryName: countryName,
                                                 State: nil,
                                                 City: nil)
            }
            
            // Perform segue
            self.performSegueWithIdentifier("Select State", sender: self)
        }
    }
    
    // MARK: Help functions
    
    /**
     Load location data from plist file "country_state_city".
     */
    private func loadLocations() {
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

extension CountryListTableViewController: CLLocationManagerDelegate {
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
        if #available(iOS 8, *) {
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

