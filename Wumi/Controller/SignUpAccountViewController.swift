//
//  SignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class SignUpAccountViewController: RegisterViewController {
    
    @IBOutlet weak var userNameTextField: SignUpTextField!
    @IBOutlet weak var userPasswordTextField: SignUpTextField!
    @IBOutlet weak var userConfirmPasswordTextField: SignUpTextField!
    @IBOutlet weak var userEmailTextField: SignUpTextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left image icon for each text field
        self.setLeftImageViewForTextField(self.userNameTextField)
        self.setLeftImageViewForTextField(self.userPasswordTextField)
        self.setLeftImageViewForTextField(self.userConfirmPasswordTextField)
        self.setLeftImageViewForTextField(self.userEmailTextField)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Add Profile" {
            if let addProfileViewController = segue.destinationViewController as? AddProfileViewController {
                addProfileViewController.user = self.user
            }
        }
    }
    
    // MARK:Actions
    override func finishForm() {
        signUpUser()
    }
    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        dismissInputView()
    }
    
    func signUpUser() -> Bool {
        
        var signUpSuccessed = true
        
        dismissInputView()
        
        self.user.validateUserWithBlock { (valid, error) -> Void in
            if !valid {
                let alert = UIAlertController(title: "Failed", message: "Invalid user information: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.showViewController(alert, sender: self)
            }
            signUpSuccessed = valid
        }
        if !signUpSuccessed { return false }
        
        self.user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            signUpSuccessed = success
        }
        if !signUpSuccessed { return false }
        
        return signUpSuccessed
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
        
        if let field = textField as? SignUpTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }
    
    // Left view of text field is used to place specific icon
    func setLeftImageViewForTextField(textField: SignUpTextField) {
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
        
        textField.setLeftImageViewForTextField(UIImage(named: imageName))
    }
}
