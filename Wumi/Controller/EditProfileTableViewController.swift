//
//  EditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var graduationYearPickerView: GraduationYearPickerView!
    
    var grayView: UIView = UIView(frame: UIScreen.mainScreen().bounds)
    
    var user:User = User.currentUser()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.enabled = true
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        
        // Initialize the graduation year picker view
        graduationYearPickerView.comfirmSelection = {
            let originalValue = self.user.graduationYear
            self.user.graduationYear = self.graduationYearPickerView.year
            self.user.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    self.loadUserData() // Update cell
                }
                else {
                    self.user.graduationYear = originalValue // Revert original value back if failed in saving changes
                    Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                }
            }
            self.grayView.removeFromSuperview()
        }
        graduationYearPickerView.cancelSelection = {
            self.grayView.removeFromSuperview()
        }
        graduationYearPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        grayView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Load user profile data
        loadUserData()
        
        super.viewWillAppear(animated)
    }
    
    func loadUserData() {
        // Show current user's account profile
        accountNameLabel.text = user.username
        emailLabel.text = user.email
        user.contact.fetchIfNeededInBackgroundWithBlock { (result, contactError) -> Void in
            if contactError != nil {
                print("\(contactError)")
                return
            }
            self.user.contact.loadAvatar(self.avatarImageView.frame.size, WithBlock: { (avatarImage, imageError) -> Void in
                if imageError == nil && avatarImage != nil {
                    self.avatarImageView.image = avatarImage
                }
                else {
                    print("\(imageError)")
                }
            })
        }
        
        // Show current user's personal information
        nameLabel.text = user.name
        if user.graduationYear == 0 {
            graduationYearLabel.text = nil
        }
        else {
            graduationYearLabel.text = "\(user.graduationYear)"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: // Profile Photo Cell
                changeProfileImage()
            case 2: // Change Password
                changePassword()
            case 3: // Email Cell
                changeEmail()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0: // Name Cell
                changeName()
            case 1: // Graduation Year Cell
                changeGraduationYear()
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
                self.user.contact.saveAvatarFile(profileImage, WithBlock: { (saveImageSuccess, imageError) -> Void in
                    if saveImageSuccess {
                        self.user.contact.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if !success {
                                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                            }
                            else {
                                self.avatarImageView.image = profileImage
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
    
    // MARK: Cell functions
    func changeProfileImage() {
        let addImageSheet = SelectPhotoActionSheet(title: "Change Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    func changePassword() {
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
    }
    
    func changeEmail() {
        Helper.PopupInputBox(self, boxTitle: "Edit Email", message: "Change your email address",
            numberOfFileds: 1, textValues: [["originalValue": user.email, "placeHolder": "Please enter your email address"]],
            WithBlock: { (inputValues) -> Void in
                let originalValue = self.user.email
                self.user.email = inputValues[0]
                self.user.saveInBackgroundWithBlock { (success, error) -> Void in
                    if success {
                        self.loadUserData() // Update cell
                    }
                    else {
                        self.user.email = originalValue // Revert original value back if failed in saving changes
                        Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                    }
                }
        })
    }
    
    func changeName() {
        Helper.PopupInputBox(self, boxTitle: "Edit Name", message: "Change your display name",
            numberOfFileds: 1, textValues: [["originalValue": user.name, "placeHolder": "Please enter your name"]],
            WithBlock: { (inputValues) -> Void in
                let originalValue = self.user.name
                self.user.name = inputValues[0]
                self.user.saveInBackgroundWithBlock { (success, error) -> Void in
                    if success {
                        self.loadUserData() // Update cell
                    }
                    else {
                        self.user.name = originalValue // Revert original value back if failed in saving changes
                        Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                    }
                }
        })
    }
    
    func changeGraduationYear() {
        graduationYearPickerView.year = user.graduationYear
        
        tabBarController!.view.addSubview(grayView)
        tabBarController!.view.addSubview(graduationYearPickerView)
        
        graduationYearPickerView.alpha = 0.0
        graduationYearPickerView.bottomAnchor.constraintEqualToAnchor(tabBarController!.view.bottomAnchor).active = true
        graduationYearPickerView.leftAnchor.constraintEqualToAnchor(tabBarController!.view.leftAnchor).active = true
        self.graduationYearPickerView.rightAnchor.constraintEqualToAnchor(self.tabBarController!.view.rightAnchor).active = true
        let heightConstraint = self.graduationYearPickerView.heightAnchor.constraintEqualToConstant(tabBarController!.tabBar.frame.size.height)
        heightConstraint.active = true
        self.tabBarController!.view.layoutIfNeeded()
        
        heightConstraint.constant = tabBarController!.view.frame.height / 3
        
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.graduationYearPickerView.alpha = 1.0
            self.tabBarController!.view.layoutIfNeeded()
        }
    }
}
