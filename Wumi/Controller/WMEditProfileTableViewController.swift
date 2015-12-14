//
//  WMEditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMEditProfileTableViewController: UITableViewController, UIPickerViewDelegate {
    
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
    
    // MARK: Actions
    func eventHandlerForSetting(setting: Setting, withCell cell: UITableViewCell) {
        switch setting.identifier {
        case "Graduation Year":
            cell.accessoryView!.becomeFirstResponder()
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
    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        self.view.endEditing(true)
        
    }
    
    // MARK: Helper functions
    func setupAccountSettingCell(cell:WMEditSettingTableViewCell, ForRow row:Int) {
        switch row {
        case 0:
            cell.initWithSetting(Setting(identifier: "UserName", type: .DisplayOnly, value: user.username))
        case 1:
            cell.initWithSetting(Setting(identifier: "Password", type: .Disclosure, value: nil))
        case 2:
            cell.initWithSetting(Setting(identifier: "Email", type: .Input, value: user.email))
        default: break
        }
    }
    
    func setupPersonalSettingCell(cell:WMEditSettingTableViewCell, ForRow row:Int) {
        switch row {
        case 0:
            cell.initWithSetting(Setting(identifier: "Name", type: .Input, value: user.name))
        case 1:
            cell.initWithSetting(Setting(identifier: "Name", type: .Input, value: user.name))
        default: break
        }
    }
    
    // MARK:View components functions
    func inputToolBar(textField: UITextField) -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolbar.barStyle = .Default;
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneToolButtonClicked:")
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }
    
    
}
