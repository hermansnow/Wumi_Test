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
    @IBOutlet weak var userInviteCodeTextField: UITextField!
    
    @IBAction func signUp(sender: UIButton) {
        signUpUser()
    }
    
    @IBAction func Cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //# MARK:TextField Delegates
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
    
    //# functions
    func signUpUser() -> Bool {
        var user = PFUser()
        
        user.username = userNameTextField.text
        user.password = userPasswordTextField.text
        user.email = userEmailTextField.text
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    var alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                })
            }
            else {
                var alert = UIAlertView(title: "Failed", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    
        return true;
    }
    

}
