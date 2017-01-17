//
//  StateListTableViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 4/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class StateListTableViewController: LocationListTableViewController {
    /// Current selected location.
    var selectedLocation: Location?
    /// State dictionary as [StateName: [Array of cities]].
    lazy var stateDict = [String: [String]]()
    /// Array of state names.
    private lazy var stateArray = [String]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stateArray = Array(stateDict.keys)
        self.stateArray.sortInPlace()
        self.buildSectionIndex(stateArray)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cityListTableViewController = segue.destinationViewController as? CityListTableViewController where segue.identifier == "Select City" {
            guard let index = self.tableView.indexPathForSelectedRow,
                sectionArray = self.sections[safe: index.section],
                stateName = sectionArray[safe: index.row] else { return }
            
            cityListTableViewController.cityArray = self.stateDict[stateName]!
            cityListTableViewController.locationDelegate = self.locationDelegate
            cityListTableViewController.selectedLocation = self.selectedLocation
        }
    }
    
    // MARK: Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationTableViewCell,
            sectionArray = self.sections[safe: indexPath.section], stateName = sectionArray[safe: indexPath.row] else {
                return UITableViewCell()
        }
        
        cell.title = stateName
        
        // Add check image if it is current selected state
        if let selectedLocation = self.selectedLocation where stateName == selectedLocation.state {
            cell.detail = "Selected"
        }
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Update selected state
        if let sectionArray = self.sections[safe: indexPath.section],
            stateName = sectionArray[safe: indexPath.row],
            _ = self.selectedLocation {
                self.selectedLocation?.state = stateName
        }
        // Perform segue
        self.performSegueWithIdentifier("Select City", sender: self)
    }
}
