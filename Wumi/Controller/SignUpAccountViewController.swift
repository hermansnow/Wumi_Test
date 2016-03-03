//
//  SignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpAccountViewController: ScrollTextFieldViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AvatarImageDelegate {
    // MARK: Properties
    
    @IBOutlet weak var addAvatarImageView: AvatarImageView!
    @IBOutlet weak var userNameTextField: DataInputTextField!
    @IBOutlet weak var userPasswordTextField: DataInputTextField!
    @IBOutlet weak var userConfirmPasswordTextField: DataInputTextField!
    @IBOutlet weak var userEmailTextField: DataInputTextField!
    @IBOutlet weak var cancelButton: SystemButton!
    
    var user = User()
    
    // MARK: Life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set cancel button
        cancelButton.recommanded = false
        
        // Set avatar image delegates
        addAvatarImageView.delegate = self
        addAvatarImageView.image = UIImage(named: "Add")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Profile Form" {
            if let addProfileViewController = segue.destinationViewController as? AddProfileViewController {
                addProfileViewController.user = self.user
                addProfileViewController.avatarImage = addAvatarImageView.image
            }
        }
    }
    
    // MARK:Actions
    
    @IBAction func signUpUser(sender: AnyObject) {
        dismissInputView()
        
        // Validate user inputs
        self.user.validateUser { (valid, error) -> Void in
            if !valid {
                Helper.PopupErrorAlert(self, errorMessage: "Invalid user information: \(error)")
                return
            }
            
            // Save avatar image file
            self.user.saveAvatarFile(self.addAvatarImageView.image) { (saveImageSuccess, imageError) -> Void in
                if !saveImageSuccess {
                    Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    return
                }
                
                // Sign up user asynchronously
                self.user.signUpInBackgroundWithBlock { (signUpSuccess, signUpError) -> Void in
                    if !signUpSuccess {
                        Helper.PopupErrorAlert(self, errorMessage: "\(signUpError)")
                        return
                    }
                    
                    self.performSegueWithIdentifier("Show Profile Form", sender: self)
                }
            }
        }
    }
    
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: TextField delegates and functions
    func textFieldDidEndEditing(textField: UITextField) {
        var error: String = ""
        
        // Validate input of each text field
        switch textField {
        case userNameTextField:
            user.username = textField.text
            if user.username?.characters.count > 0 {
                user.validateUserName(&error)
            }
        case userPasswordTextField:
            user.password = textField.text
            if let confirmPassword = user.confirmPassword {
                if confirmPassword.characters.count > 0 {
                    user.validateConfirmPassword(&error)
                    //userConfirmPasswordTextField.setRightErrorViewForTextFieldWithErrorMessage(error)
                }
            }
            error = ""
            if user.password!.characters.count > 0 {
                user.validateUserPassword(&error)
            }
        case userConfirmPasswordTextField:
            user.confirmPassword = textField.text
            if user.confirmPassword!.characters.count > 0 {
                user.validateConfirmPassword(&error)
            }
        case userEmailTextField:
            user.email = textField.text
        default:
            break
        }
    }
    
    // MARK: UIImagePicker delegates and functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let avatarImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.addAvatarImageView.image = avatarImage
            }
        }
    }
    
    // MARK: AvatarImageView delegates and functions
    func singleTap(imageView: AvatarImageView) {
        let addImageSheet = SelectPhotoActionSheet(title: "Add Avatar Image", message: "Choose a photo as your avatar image.", preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
}
