//
//  StateListTableViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 4/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class StateListTableViewController: UITableViewController {

    var countryName = String()
    lazy var stateDict = [String: [String]]()
    lazy var stateArray = [String]()
    var selectedLocation: Location?
    var locationDelegate: LocationListDelegate?
    
    // Add index collation
    lazy var collation = UILocalizedIndexedCollation.currentCollation()
    lazy var sections = [[String]]()
    lazy var sectionTitles = [String]()
    lazy var sectionIndexTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.sectionIndexBackgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        stateArray = Array(stateDict.keys)
        stateArray.sortInPlace()
        self.buildSectionIndex(stateArray)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionArray = self.sections[safe: section] else { return 0 }
        return sectionArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String] {
        return self.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("State Cell", forIndexPath: indexPath)
        
        switch indexPath.section {
        default:
            guard let sectionArray = self.sections[safe: indexPath.section], stateName = sectionArray[safe: indexPath.row] else { break }
            cell.textLabel!.text = stateName
            
            cell.accessoryType = .DisclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        default: break
//            guard let sectionArray = self.sections[safe: indexPath.section], cityName = sectionArray[safe: indexPath.row] else { break }
//            self.selectedLocation = Location(Country: countryName, City: cityName)
//            if let location = selectedLocation, delegate = locationDelegate {
//                delegate.finishLocationSelection(location)
//            }
//            self.navigationController?.popToViewController(locationDelegate as! UIViewController, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cityListTableViewController = segue.destinationViewController as? CityListTableViewController where segue.identifier == "Select City" {
            guard let index = self.tableView.indexPathForSelectedRow else { return }
            guard let sectionArray = self.sections[safe: index.section], stateName = sectionArray[safe: index.row] else { return }
            cityListTableViewController.countryName = countryName
            cityListTableViewController.stateName = stateName
            cityListTableViewController.cityArray = stateDict[stateName]!
            
            cityListTableViewController.locationDelegate = self.locationDelegate
            cityListTableViewController.selectedLocation = self.selectedLocation
        }
    }
    
    // MARK: - Helper functions
    
    private func buildSectionIndex(states: [String]) {
        // Reser collasion
        self.collation = UILocalizedIndexedCollation.currentCollation()
        
        var sectionArrays: [[String]] = Array(count: self.collation.sectionTitles.count, repeatedValue: [String]())
        
        for state in states {
            let sectionIndex = collation.sectionForObject(state, collationStringSelector: Selector("self"))
            sectionArrays[sectionIndex].append(state)
        }
        
        for sectionIndex in 0...sectionArrays.count {
            guard let section = sectionArrays[safe: sectionIndex] where section.count > 0 else { continue }
            
            self.sections.append(section)
            self.sectionTitles.append(self.collation.sectionTitles[sectionIndex])
            self.sectionIndexTitles.append(self.collation.sectionIndexTitles[sectionIndex])
        }
    }

}
