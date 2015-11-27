//
//  WMEditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMEditProfileTableViewController: UITableViewController {
    
    var accountSettings = [Setting]()
    var personalSettings = [Setting]()
    var sections = [[Setting]]()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Get log in user
        user = User.currentUser()!
        
        setupSections()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    // MARK: tableview delegates
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section < self.sections.count ? self.sections[section].count : 0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let cellIdentifier = "Profile Cell"
        
        // Reuse cell
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            cell = reuseCell
        }
        else {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
        }
        
        // Get related setting
        if let setting = settingForIndexPath(indexPath) {
            // Set display name for the cell
            cell.textLabel!.text = setting.title
            
            // Set accessory view
            switch setting.type {
            case .DisclosureCell:
                cell.accessoryType = .DisclosureIndicator
                cell.accessoryView = nil
            case .DisplayCell:
                cell.accessoryType = .None
                cell.accessoryView = nil
            default:
                break
            }
            
            // Set detail text
            cell.detailTextLabel?.text = setting.detail
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        if let setting = settingForIndexPath(indexPath) {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                eventHandlerForSetting(setting, withCell: cell)
            }
        }
    }
    
    // MARK: Actions
    func eventHandlerForSetting(setting: Setting, withCell: UITableViewCell) {
        switch setting.identifier {
        default:
            break
        }
    }
    
    // MARK: Helper functions
    func setupSections() {
        setupAccountSettings()
        setupPersonalSettings()
        self.sections.append(self.accountSettings)
        self.sections.append(self.personalSettings)
    }
    
    func setupAccountSettings() {
        self.accountSettings.append(Setting(identifier: "Account", title: "Account", type: .DisplayCell, detail: user.username, selector:nil ,userDefaultKey:nil))
        self.accountSettings.append(Setting(identifier: "Password", title: "Password", type: .DisclosureCell, detail: nil, selector:nil ,userDefaultKey:nil))
    }
    
    func setupPersonalSettings() {
        self.personalSettings.append(Setting(identifier: "Name", title: "Name", type: .DisclosureCell, detail: user.name, selector:nil ,userDefaultKey: nil))
        self.personalSettings.append(Setting(identifier: "Graduation Year", title: "Graduation Year", type: .DisclosureCell, detail: "\(user.graduationYear)", selector: nil, userDefaultKey: nil))
    }
    
    func settingForIndexPath(indexPath: NSIndexPath) -> Setting? {
        if indexPath.section >= self.sections.count {
            return nil
        }
        
        if indexPath.row >= self.sections[indexPath.section].count {
            return nil
        }
        
        return self.sections[indexPath.section][indexPath.row]
    }
    
    
}
