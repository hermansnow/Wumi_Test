//
//  SettingTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import SWRevealViewController
import MessageUI

class SettingTableViewController: DataLoadingTableViewController {
    
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    
    private var settings: [[Setting]] =
        [[Setting(identifier: "Account", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Email Settings", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Mobile Notifications", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Invite Others", type: Setting.SettingType.Disclosure, value: nil),
            Setting(identifier: "Cache Setting", type: Setting.SettingType.Disclosure, value: nil)],
         [Setting(identifier:"Log Out", type: .Button, value: nil)]]
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize tableview
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Register table cell nib
        self.tableView.registerNib(UINib(nibName: "SettingTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "SettingCell")
    }

    // MARK: tableview delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.settings.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settings = self.settings[safe: section] else {
            return 0
        }
        
        return settings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = self.settings[safe: indexPath.section], setting = section[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        // Generate cell based on cell type
        switch (indexPath.section) {
        // Setting cell
        case 0:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell") as? SettingTableViewCell else {
                return UITableViewCell()
            }
            
            cell.title = setting.identifier
            if setting.type == .Disclosure {
                cell.accessoryType = .DisclosureIndicator
            }
            
            return cell
        // Logout cell
        case 1:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell") else {
                return UITableViewCell()
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        // Handle setting
        if let section = self.settings[safe: indexPath.section], setting = section[safe: indexPath.row] {
            self.eventHandlerForSetting(setting)
        }
        
        // Deselect cell after handling
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: Actions
    
    /**
     Close the setting view controller.
     */
    @IBAction func closeSettingView(sender: AnyObject) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    /**
     Trigger event for clicking each setting cell.
     
     - Parameters:
        - setting: Setting was selected.
     */
    private func eventHandlerForSetting(setting: Setting) {
        switch setting.identifier {
        case "Account":
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Right, animated: true)
            self.performSegueWithIdentifier("Edit Profile", sender: self)
        case "Invite Others":
            self.sendInviteEmail()
        case "Cache Setting":
            self.performSegueWithIdentifier("Cache Setting", sender: self)
        case "Log Out":
            self.logoutUser()
        default:
            break
        }
    }
    
    /**
     Present a mail composer to send an invitation email from current login user.
     */
    private func sendInviteEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Mail services are not available")
            return
        }
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Generate a new code
        let inviteCode = InvitationCode()
        inviteCode.userName = self.currentUser.name
        inviteCode.generateNewCode { (success, error) in
            self.dismissLoadingIndicator()
            
            guard let code = inviteCode.invitationCode where success && error == nil else {
                if let wumiError = error {
                    ErrorHandler.popupErrorAlert(self, errorMessage: wumiError.error)
                }
                else {
                    ErrorHandler.popupErrorAlert(self, errorMessage: "Failed to generate an invitation code.")
                }
                return
            }
            
            mailComposeVC.setMessageBody("Come to use Wumi App!\n My Invitation code is \(code)!", isHTML: false)
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
        }
    }
    
    /**
     Present a popup alert for logging out current user.
     */
    private func logoutUser() {
        let alert = UIAlertController(title: "Log Out?",
                                      message: "Logout will not delete any data. You can still log in with this account. ",
                                      preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .Default) { (UIAlertAction) -> Void in
            CDChatManager.sharedManager().closeWithCallback( {(success, error) -> Void in
                guard success else{
                    ErrorHandler.popupErrorAlert(self, errorMessage: "\(error)")
                    return
                }
                
                Helper.LogOut()
            })
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: MFMailComposeViewController delegate

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result) {
        case .Sent:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is sent successfully")
        case .Saved:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is saved in draft folder")
        case .Cancelled:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is cancelled")
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
