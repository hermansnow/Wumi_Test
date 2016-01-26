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
    
    var user:User = User.currentUser()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.enabled = true
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Show current user's profile  
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
        
        super.viewWillAppear(animated)
    }
    
    // MARK: Action
    @IBAction func updateProfileImage(sender: AnyObject) {
        let addImageSheet = SelectPhotoActionSheet(title: "Change Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    // MARK: UIImagePicker delegates and functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.userProfileImageButton.setBackgroundImage(profileImage, forState: .Normal)
                self.user.saveProfileImageFile(profileImage, WithBlock: { (success, error) -> Void in
                    if !success {
                        Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
                    }
                })
            }
        }
    }
}
