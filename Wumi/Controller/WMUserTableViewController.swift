//
//  WMUserTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMUserTableViewController: UITableViewController {
    
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    
    var user = User.currentUser()!
    
    var sections: [[Setting]] =
        [[Setting(identifier: "User Profile", type: .DisplayOnly, value: nil)],
        [Setting(identifier: "Contact", type: .Disclosure, value: nil)],
        [Setting(identifier:"Log Out", type: .Button, value: nil)]]
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show current user's profile
        userDisplayName.text = user.name
        userEmail.text = user.email
        user.loadProfileImageWithBlock { (imageData, error) -> Void in
            if error == nil && imageData != nil {
                self.userProfileImageView.image = UIImage(data: imageData!)
            }
            else {
                print("\(error)")
            }
        }
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
            User.logOutInBackgroundWithBlock({ (error) -> Void in
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
