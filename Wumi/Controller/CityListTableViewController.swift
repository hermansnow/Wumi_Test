//
//  CityListTableViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 3/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CityListTableViewController: UITableViewController {
    
    var countryName = String()
    var stateName = String()
    lazy var cityArray = [String]()
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
        self.buildSectionIndex(cityArray)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("City Cell", forIndexPath: indexPath)

        switch indexPath.section {
        default:
            guard let sectionArray = self.sections[safe: indexPath.section], city = sectionArray[safe: indexPath.row] else { break }
            cell.textLabel!.text = city
            
            // Add checkmark for selected country
            if let location = self.selectedLocation where location.country == countryName && location.city == city {
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
        default:
            guard let sectionArray = self.sections[safe: indexPath.section], cityName = sectionArray[safe: indexPath.row] else { break }
            self.selectedLocation = Location(Country: countryName, State: stateName, City: cityName)
            if let location = selectedLocation, delegate = locationDelegate {
                delegate.finishLocationSelection(location)
            }
            self.navigationController?.popToViewController(locationDelegate as! UIViewController, animated: true)
        }
    }

    // MARK: - Helper functions
    
    private func buildSectionIndex(data: [String]) {
        // Reser collasion
        self.collation = UILocalizedIndexedCollation.currentCollation()
        
        var sectionArrays: [[String]] = Array(count: self.collation.sectionTitles.count, repeatedValue: [String]())
        
        for city in data {
            let sectionIndex = collation.sectionForObject(city, collationStringSelector: Selector("self"))
            sectionArrays[sectionIndex].append(city)
        }
        
        for sectionIndex in 0...sectionArrays.count {
            guard let section = sectionArrays[safe: sectionIndex] where section.count > 0 else { continue }
            
            self.sections.append(section)
            self.sectionTitles.append(self.collation.sectionTitles[sectionIndex])
            self.sectionIndexTitles.append(self.collation.sectionIndexTitles[sectionIndex])
        }
    }

}
