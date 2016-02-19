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

class CountryListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var countryList = [String]()
    var selectedCountry: String?
    var locationManager = CLLocationManager()
    var currentLocation: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        locationManager.delegate = self
        
        loadCountries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        var countryName: String?
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
            
            if currentLocation == nil {
                cell.textLabel!.text = "Grabbing current location"
                countryName = nil
            }
            else {
                cell.textLabel!.text = currentLocation?.country
                countryName = currentLocation?.country
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("Country Cell", forIndexPath: indexPath)
            
            countryName = countryList[indexPath.row]
            cell.textLabel!.text = countryName
        default:
            break
        }
        
        // Add checkmark for selected country
        if countryName == selectedCountry {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            selectedCountry = cell.textLabel!.text
            tableView.reloadData()
        }
    }
    
    // MARK: CLLocationManager delegates
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation) { (result, error) -> Void in
            if let locations = result {
                if locations.count > 0 {
                    self.currentLocation = locations.first
                    self.tableView.reloadData()
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
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
        
        getCurrentLocation()
    }
    
    private func getCurrentLocation() -> Void {
        if Double(UIDevice.currentDevice().systemVersion) > 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            locationManager.startUpdatingLocation()
        }
    }
}

