//
//  WMUserTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import SWRevealViewController
import MessageUI

class WMUserTableViewController: UITableViewController {
    
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    
    var user = User.currentUser()!
    
    var sections: [[Setting]] =
        [[Setting(identifier: "User Profile", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Email Settings", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Mobile Notifications", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Invite Others", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Cache Setting", type: Setting.SettingType.Disclosure, value: nil)],
        [Setting(identifier:"Log Out", type: .Button, value: nil)]]
    
    var hasEnterMenu = false
    
    let DEFAULT_REVEAL_WIDTH: CGFloat = 260.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        case "Invite Others":
            sendInviteEmail()
        case "Cache Setting":
            self.performSegueWithIdentifier("Cache Setting", sender: self)
        case "Log Out":
            self.logoutUser()
        default:
            break
        }
    }
    
    func sendInviteEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            
            let inviteCode = InvitationCode()
            inviteCode.userName = user.name
            inviteCode.generateNewCode()
            
            mailComposeVC.setMessageBody("Come to use Wumi App!\n My Invitation code is \(inviteCode.invitationCode!)!", isHTML: false)
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
        }
        else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Mail services are not available")
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
    
    // MARK: Helper functions
    func generateInviteCode() {
        
    }
    
}

extension WMUserTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result) {
        case .Sent:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is sent successfully")
        case .Saved:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is saved in draft folder")
        case .Cancelled:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is cancelled")
        case .Failed:
            if error != nil {
                ErrorHandler.popupErrorAlert(self, errorMessage: (error?.localizedDescription)!)
            }
            else {
                ErrorHandler.popupErrorAlert(self, errorMessage: "Send failed")
            }
        }
        
        // Dimiss the main compose view controller
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
