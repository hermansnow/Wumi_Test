//
//  WMUserTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMUserTableViewController: UITableViewController {
    
    var profileSettings = [Setting]()
    var logoutSettings = [Setting]()
    var sections = [[Setting]]()
    var userDefault = NSUserDefaults.standardUserDefaults()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Get log in user
        self.user = User.currentUser()!
        
        setupUserSections()
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
        let cellIdentifier = "Setting Cell"
        
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
            case .SwitchCell:
                let switchView = UISwitch()
                switchView.setOn(self.userDefault.boolForKey(setting.relatedUserDefaultKey!), animated: false)
                switchView.addTarget(self, action: setting.seletor!, forControlEvents: .ValueChanged)
                cell.accessoryType = .None
                cell.accessoryView = switchView
            case .ButtonCell:
                cell.textLabel?.textColor = UIColor.redColor()
            default:
                break;
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
        case "User Profile":
            self.performSegueWithIdentifier("Edit Profile", sender: self)
        case "Log Out":
            let alert = UIAlertController(title: "Log Out?", message: "Logout will not delete any data. You can still log in with this account. ", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { (UIAlertAction) -> Void in
                PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                    if error != nil {
                        // TODO alert
                    }
                    else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("Log In View Controller")
                        self.presentViewController(loginViewController, animated: true, completion: nil)
                    }
                })
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: Helper functions
    func setupUserSections() {
        setupProfileSettings()
        setupLogoutSettings()
        self.sections.append(self.profileSettings)
        self.sections.append(self.logoutSettings)
    }
    
    func setupProfileSettings() {
        self.profileSettings.append(Setting(identifier:"User Profile", title: self.user.name!, type: .DisclosureCell, detail: user.email, selector:nil ,userDefaultKey:nil))
    }
    
    func setupLogoutSettings() {
        self.logoutSettings.append(Setting(identifier:"Log Out", title: "Log Out", type: .ButtonCell, detail: nil, selector:"logoutUser:" ,userDefaultKey: nil))
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
