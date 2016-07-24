//
//  WMUserTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import SWRevealViewController

class WMUserTableViewController: UITableViewController {
    
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    
    var user = User.currentUser()!
    
    var sections: [[Setting]] =
        [[Setting(identifier: "User Profile", type: Setting.SettingType.Disclosure, value: nil)],
        [Setting(identifier:"Log Out", type: .Button, value: nil)]]
    
    var hasEnterMenu = false
    
    let DEFAULT_REVEAL_WIDTH: CGFloat = 260.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show current user's profile
//        userDisplayName.text = user.name
//        userEmail.text = user.email
//        self.user.loadAvatarThumbnail() { (avatarImage, imageError) -> Void in
//            if imageError == nil && avatarImage != nil {
//                self.userProfileImageView.image = avatarImage
//            }
//            else {
//                print("\(imageError)")
//            }
//        }
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
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Right, animated: true)
            self.performSegueWithIdentifier("Edit Profile", sender: self)
        case "Log Out":
            self.logoutUser()
        default:
            break
        }
    }
    
    func logoutUser() {
        let alert = UIAlertController(title: "Log Out?", message: "Logout will not delete any data. You can still log in with this account. ", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .Default) { (UIAlertAction) -> Void in
            CDChatManager.sharedManager().closeWithCallback( {(succeeded, error) -> Void in
                if succeeded {
                    Helper.LogOut()
                }
            })
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeSettingView(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
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
