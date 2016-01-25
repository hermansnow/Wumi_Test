//
//  SignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpAccountViewController: ScrollTextFieldViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var addProfileImageButton: UIButton!
    @IBOutlet weak var userNameTextField: DataInputTextField!
    @IBOutlet weak var userPasswordTextField: DataInputTextField!
    @IBOutlet weak var userConfirmPasswordTextField: DataInputTextField!
    @IBOutlet weak var userEmailTextField: DataInputTextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Frame will change after ViewWillAppear because of AutoLayout.
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set circular profile image button
        addProfileImageButton.layer.cornerRadius = addProfileImageButton.frame.size.height / 2
        addProfileImageButton.clipsToBounds = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Profile Form" {
            if let addProfileViewController = segue.destinationViewController as? AddProfileViewController {
                addProfileViewController.user = self.user
            }
        }
    }
    
    // MARK:Actions
    @IBAction func signUpUser(sender: AnyObject) {
        dismissInputView()
        
        // Validate user inputs
        self.user.validateUserWithBlock { (valid, error) -> Void in
            if !valid {
                Helper.PopupErrorAlert(self, errorMessage: "Invalid user information: \(error)", dismissButtonTitle: "Cancel")
            }
            else {
                self.user.saveProfileImageFileWithBlock({ (success, error) -> Void in
                    if !success {
                        Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
                    }
                    else {
                        // Sign up user asynchronously
                        self.user.signUpInBackgroundWithBlock { (success, error) -> Void in
                            if !success {
                                Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
                            }
                            else {
                                self.performSegueWithIdentifier("Show Profile Form", sender: self)
                            }
                        }
                    }
                })
            }
        }
    }
    
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Click to select a image as profile image
    @IBAction func addImage(sender: AnyObject) {
        let addImageSheet = UIAlertController(title: "Add Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
        
        addImageSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        addImageSheet.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
            self.openPhotoLibrary()
        }))
        
        addImageSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    // MARK: TextField delegates and functions
    func textFieldDidEndEditing(textField: UITextField) {
        var error: String = ""
        
        // Validate input of each text field
        switch textField {
        case self.userNameTextField:
            self.user.username = textField.text
            if self.user.username?.characters.count > 0 {
                user.validateUserName(&error)
            }
        case self.userPasswordTextField:
            self.user.password = textField.text
            if let confirmPassword = self.user.confirmPassword {
                if confirmPassword.characters.count > 0 {
                    user.validateConfirmPassword(&error)
                    self.userConfirmPasswordTextField.setRightErrorViewForTextFieldWithErrorMessage(error)
                }
            }
            error = ""
            if self.user.password!.characters.count > 0 {
                user.validateUserPassword(&error)
            }
        case self.userConfirmPasswordTextField:
            self.user.confirmPassword = textField.text
            if self.user.confirmPassword!.characters.count > 0 {
                user.validateConfirmPassword(&error)
            }
        case self.userEmailTextField:
            self.user.email = textField.text
        default:
            break
        }
        
        if let field = textField as? DataInputTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }
    
    // MARK: UIImagePicker delegates and functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.addProfileImageButton.setBackgroundImage(profileImage, forState: .Normal)
                self.user.profileImage = profileImage
            }
        }
    }
    
    // Open Camera to take a photo
    func openCamera() {
        // Check whether camera device is available
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            Helper.PopupErrorAlert(self, errorMessage: "Camera device is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        imagePicker.mediaTypes = ["\(kUTTypePNG)"]
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Open local photo library
    func openPhotoLibrary() {
        // Check whether photo library is available
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            Helper.PopupErrorAlert(self, errorMessage: "Photo library is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}
