//
//  CityListTableViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 3/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CityListTableViewController: LocationListTableViewController {
    /// Current selected location.
    var selectedLocation: Location?
    /// Array of city names.
    lazy var cityArray = [String]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildSectionIndex(cityArray)
    }

    // MARK: Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationTableViewCell,
            sectionArray = self.sections[safe: indexPath.section], cityName = sectionArray[safe: indexPath.row] else {
                return UITableViewCell()
        }
        
        cell.title = cityName
        
        // Add check image if it is current selected country
        if let selectedLocation = self.selectedLocation where cityName == selectedLocation.city {
            cell.detail = "Selected"
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionArray = self.sections[safe: indexPath.section], cityName = sectionArray[safe: indexPath.row] else {
            return
        }
        
        if var location = self.selectedLocation, let delegate = locationDelegate {
            location.city = cityName
            delegate.finishLocationSelection(location)
        }
        self.navigationController?.popToViewController(locationDelegate as! UIViewController, animated: true)
    }
}
