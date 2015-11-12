//
//  WMProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMProfileTableViewController: UITableViewController {
    
    // MARK: TableView delegates
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let cellIdentifier = ""
        
        return cell
    }
}
