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
    
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    var sections: [[Setting]] =
        [[Setting(identifier: "User Profile", type: .DisplayOnly, value: nil)],
        [Setting(identifier: "Contact", type: .Disclosure, value: nil)],
        [Setting(identifier:"Log Out", type: .Button, value: nil)]]
    var userDefault = NSUserDefaults.standardUserDefaults()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get log in user
        self.user = User.currentUser()!
        
        // Show current user's profile
        self.userDisplayName.text = user.name
        self.userEmail.text = user.email
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
        
        super.viewDidAppear(animated)
    }
    
    // MARK: tableview delegates
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
        case "Cantact":
            self.performSegueWithIdentifier("Contact Settings", sender: self)
        case "Log Out":
            self.logoutUser()
        default:
            break
        }
    }
    
    func logoutUser() {
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
    }
    
    // MARK: Setting functions
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
