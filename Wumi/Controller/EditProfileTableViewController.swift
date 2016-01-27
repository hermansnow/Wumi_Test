//
//  EditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class EditProfileTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userProfileImageButton: UIButton!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user:User = User.currentUser()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.enabled = true
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Show current user's account profile
        accountNameLabel.text = user.username
        emailLabel.text = user.email
        user.loadProfileImageWithBlock { (imageData, error) -> Void in
            if error == nil && imageData != nil {
                self.userProfileImageButton.setBackgroundImage(UIImage(data: imageData!), forState: .Normal)
            }
            else {
                print("\(error)")
            }
        }
        
        // Show current user's personal information
        nameLabel.text = user.name
        
        super.viewWillAppear(animated)
    }
    
    // MARK: tableview delegates
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            // Profile Photo Cell
            case 0:
                let addImageSheet = SelectPhotoActionSheet(title: "Change Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
                addImageSheet.delegate = self
                addImageSheet.launchViewController = self
                
                presentViewController(addImageSheet, animated: true, completion: nil)
            // Change Password
            case 2:
                Helper.PopupInputBox(self, boxTitle: "Change Password", message: "Please input a new password",
                    numberOfFileds: 2, textValues: [["placeHolder": "Please enter a new password"], ["placeHolder": "Please confirm the new password"]],
                    WithBlock: { (inputValues) -> Void in
                        let newPassword = inputValues[0]
                        let confirmPassword = inputValues[1]
                        self.user.password = newPassword
                        self.user.confirmPassword = confirmPassword
                        self.user.validateUserWithBlock({ (valid, validateError) -> Void in
                            if !valid {
                                Helper.PopupErrorAlert(self, errorMessage: "\(validateError)")
                                // Do not save anything in password properties
                                self.user.password = nil
                                self.user.confirmPassword = nil
                                return
                            }
                            
                            self.user.saveInBackgroundWithBlock { (success, error) -> Void in
                                if !success {
                                    Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                                }
                                // Do not save anything in password properties
                                self.user.password = nil
                                self.user.confirmPassword = nil
                            }
                        })
                })
            // Email Cell
            case 3:
                Helper.PopupInputBox(self, boxTitle: "Edit Email", message: "Change your email address",
                    numberOfFileds: 1, textValues: [["originalValue": user.email!, "placeHolder": "Please enter your email address"]],
                    WithBlock: { (inputValues) -> Void in
                        let originalValue = self.user.email
                        self.user.email = inputValues[0]
                        self.user.saveInBackgroundWithBlock { (success, error) -> Void in
                            if success {
                                self.emailLabel.text = self.user.email // Update
                            }
                            else {
                                self.user.email = originalValue // Revert original value back if failed in saving changes
                                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                            }
                        }
                })
            default:
                break
            }
        default:
            break
        }
        
        // Reset cell selection status
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }
    
    // MARK: UIImagePicker delegates and functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.userProfileImageButton.setBackgroundImage(profileImage, forState: .Normal)
                self.user.saveProfileImageFile(profileImage, WithBlock: { (saveImageSuccess, imageError) -> Void in
                    if saveImageSuccess {
                        self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if !success {
                                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                            }
                        })
                    }
                    else {
                        Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    }
                })
            }
        }
    }
}
