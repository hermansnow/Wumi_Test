//
//  RegisterViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userConfirmPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var graduationYearTextField: UITextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLeftImageViewForTextField(self.userNameTextField)
        self.setLeftImageViewForTextField(self.userPasswordTextField)
        self.setLeftImageViewForTextField(self.userConfirmPasswordTextField)
        self.setLeftImageViewForTextField(self.userEmailTextField)
        self.setLeftImageViewForTextField(self.graduationYearTextField)
        
        // Set Date Picker for graduationYearTextField
        let graduationYearPicker = UIDatePicker()
        graduationYearPicker.datePickerMode = UIDatePickerMode.Date
        self.graduationYearTextField.inputView = graduationYearPicker
    }
    
    // MARK:Actions
    @IBAction func Cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: UIButton) {
        signUpUser()
    }
    
    // MARK:TextField delegates and functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
            signUpUser()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var error: String = ""
        
        // Validate input of each text field
        switch textField {
        case self.userNameTextField:
            self.user.username = textField.text
            if (self.user.username?.characters.count > 0) {
                user.validateUserName(&error)
            }
        case self.userPasswordTextField:
            self.user.password = textField.text
            if let confirmPassword = self.user.confirmPassword {
                if (confirmPassword.characters.count > 0) {
                    user.validateConfirmPassword(&error)
                    self.setRightImageViewForTextField(self.userConfirmPasswordTextField, error: error)
                }
            }
            error = ""
            if (self.user.password!.characters.count > 0) {
                user.validateUserPassword(&error)
            }
        case self.userConfirmPasswordTextField:
            self.user.confirmPassword = textField.text
            if (self.user.confirmPassword!.characters.count > 0) {
                user.validateConfirmPassword(&error)
            }
        case self.userEmailTextField:
            self.user.email = textField.text
        default:
             break
        }
        
        self.setRightImageViewForTextField(textField, error: error)
    }
    
    // Right view of text field is used to show error image if the input is invalid
    func setRightImageViewForTextField(textField: UITextField, error: String = "") {
        if (error.characters.count == 0) {
            textField.rightView = nil
        }
        else {
            //Add Error right image view
            let rightErrorView = UIImageView(image: UIImage(named: "Error"))
            rightErrorView.frame = CGRectMake(0, 1, 30, textField.bounds.height - 2)
            textField.rightView = rightErrorView
            textField.rightViewMode = UITextFieldViewMode.Always
        
            //Log error
            print("\(error)")
        }
    }
    
    // Left view of text field is used to place the icon
    func setLeftImageViewForTextField(textField: UITextField) {
        var imageName = ""
        var leftImageView: UIImageView = UIImageView()
        
        switch textField {
        case self.userNameTextField:
            imageName = "Name"
        case self.userPasswordTextField, self.userConfirmPasswordTextField:
            imageName = "Password"
        case self.userEmailTextField:
            imageName = "Email"
        case self.graduationYearTextField:
            imageName = "Grad"
        default:
            break;
        }
        
        if (imageName.characters.count > 0) {
            leftImageView = UIImageView(image: UIImage(named: imageName))
            leftImageView.frame = CGRectMake(0, 0, 30, textField.bounds.height)
            textField.leftView = leftImageView
            textField.leftViewMode = UITextFieldViewMode.Always
        }
    }
    
    //# functions
    func signUpUser() -> Bool {
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.showViewController(alert, sender: self)
                })
            }
            else {
                let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.showViewController(alert, sender: self)
            }
        }
    
        return true;
    }
    

}
