//
//  WMEditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMEditProfileTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem?.enabled = true
        
        self.tableView.registerNib(UINib(nibName: "WMEditSettingCell", bundle: nil), forCellReuseIdentifier: "Setting Cell")
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Get log in user
        user = User.currentUser()!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    // MARK: tableview delegates
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Account Information"
        case 1:
            return "Personal Information"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:WMEditSettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("Setting Cell") as! WMEditSettingTableViewCell
        
        switch indexPath.section {
        case 0:
            setupAccountSettingCell(cell, ForRow: indexPath.row)
        case 1:
            setupPersonalSettingCell(cell, ForRow: indexPath.row)
        default: break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as! WMEditSettingTableViewCell? {
            eventHandlerForSetting(cell.setting!, withCell: cell)
        }
    }
    
    // MARK: textfield delegates
    func textFieldDidEndEditing(textField: UITextField) {
        if let cell = textField.superview?.superview as! WMEditSettingTableViewCell? {
            switch cell.setting!.identifier {
            case "Email":
                self.user.email = textField.text
            case "Name":
                self.user.name = textField.text
            default: break
            }
        }
    }
    
    // MARK: Actions
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveProfile(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if !success {
                let alert = UIAlertController(title: "Failed", message: "Failed in editting profile: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    
    func eventHandlerForSetting(setting: Setting, withCell cell: UITableViewCell) {
        switch setting.identifier {
        default:
            break
        }
    }
    
    // MARK: Helper functions
    func setupAccountSettingCell(cell:WMEditSettingTableViewCell, ForRow row:Int) {
        switch row {
        case 0:
            cell.initWithSetting(Setting(identifier: "UserName", type: .DisplayOnly, value: user.username))
        case 1:
            cell.initWithSetting(Setting(identifier: "Password", type: .Disclosure, value: nil))
        case 2:
            cell.initWithSetting(Setting(identifier: "Email", type: .Input, value: user.email), WithTextFieldDelegate:self)
        default: break
        }
    }
    
    func setupPersonalSettingCell(cell:WMEditSettingTableViewCell, ForRow row:Int) {
        switch row {
        case 0:
            cell.initWithSetting(Setting(identifier: "Name", type: .Input, value: user.name), WithTextFieldDelegate:self)
        case 1:
            cell.initWithSetting(Setting(identifier: "Name", type: .Input, value: user.name), WithTextFieldDelegate:self)
        default: break
        }
    }
}
