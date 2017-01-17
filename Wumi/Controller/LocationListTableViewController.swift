//
//  LocationListTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/16/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class LocationListTableViewController: UITableViewController {
    /// LocagtionList delegate.
    var locationDelegate: LocationListDelegate?
    
    // Table index collation
    
    /// Index collation.
    lazy var collation = UILocalizedIndexedCollation.currentCollation()
    /// Index collation section array.
    lazy var sections = [[String]]()
    /// Title string for each index collation sections.
    lazy var sectionTitles = [String]()
    /// Title string for each indexes.
    lazy var sectionIndexTitles = [String]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view
        self.tableView.sectionIndexBackgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "LocationTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "LocationCell")
    }
    
    // MARK: UI functions
    
    /**
     Build and show section index for the table on right.
     
     - Parameters:
        - data: data to be displayed on table.
     */
    func buildSectionIndex(data: [String]) {
        // Reset collation
        self.collation = UILocalizedIndexedCollation.currentCollation()
        
        // Initial a section array
        var sectionArrays: [[String]] = Array(count: self.collation.sectionTitles.count, repeatedValue: [String]())
        
        // Parse all display data to sections
        for item in data {
            let sectionIndex = collation.sectionForObject(item, collationStringSelector: #selector(NSObject.selfMethod))
            sectionArrays[sectionIndex].append(item)
        }
        
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
}

// MARK: Custome delegate

protocol LocationListDelegate {
    /**
     Event when user selects a new location and navigate back to its parent view controller.
     
     - Parameters:
        - location: New selected location.
     */
    func finishLocationSelection(location: Location?)
}

