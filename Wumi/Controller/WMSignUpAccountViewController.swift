//
//  WMSignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMSignUpAccountViewController: WMRegisterViewController {
    
    @IBOutlet weak var userNameTextField: WMDataInputTextField!
    @IBOutlet weak var userPasswordTextField: WMDataInputTextField!
    @IBOutlet weak var userConfirmPasswordTextField: WMDataInputTextField!
    @IBOutlet weak var userEmailTextField: WMDataInputTextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left image icon for each text field
        self.setLeftIconForTextField(self.userNameTextField)
        self.setLeftIconForTextField(self.userPasswordTextField)
        self.setLeftIconForTextField(self.userConfirmPasswordTextField)
        self.setLeftIconForTextField(self.userEmailTextField)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Profile Form" {
            if let addProfileViewController = segue.destinationViewController as? WMAddProfileViewController {
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
                let alert = UIAlertController(title: "Failed", message: "Invalid user information: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                // Sign up user asynchronously
                self.user.signUpInBackgroundWithBlock { (success, error) -> Void in
                    if !success {
                        let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        self.performSegueWithIdentifier("Show Profile Form", sender: self)
                    }
                }
            }
        }
    }
    
    // MARK:TextField delegates and functions
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
        
        if let field = textField as? WMDataInputTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }
    
    // Left view of text field is used to place specific icon
    func setLeftIconForTextField(textField: WMDataInputTextField) {
        var imageName = ""
        
        switch textField {
        case self.userNameTextField:
            imageName = "Name"
        case self.userPasswordTextField, self.userConfirmPasswordTextField:
            imageName = "Password"
        case self.userEmailTextField:
            imageName = "Email"
        default:
            break;
        }
        
        if let image = UIImage(named: imageName) {
            textField.setLeftImageViewForTextField(image)
        }
    }
}
