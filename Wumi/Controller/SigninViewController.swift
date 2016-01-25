//
//  SigninViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SigninViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: DataInputTextField!
    @IBOutlet weak var passwordTextField: DataInputTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Get current user
        if User.currentUser() != nil {
            //self.performSegueWithIdentifier("Launch Main View", sender: self)
        }
    }
    
    // Perform segues: "Launch Main View" to main view
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Launch Main View" {
            return User.currentUser() != nil
        }
        
        return true
    }
    
    // MARK: Actions
    @IBAction func SignIn(sender: AnyObject) {
        
        let userName = self.usernameTextField.text
        let userPassword = self.passwordTextField.text
        
        User.logInWithUsernameInBackground(userName!, password: userPassword!) { (pfUser, error) -> Void in
            if pfUser == nil {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
            }
            else {
                self.performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Password", message: "Please enter the email address for your account", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            if let textField = alert.textFields?.first {
                User.requestPasswordResetForEmailInBackground(textField.text!, block: { (success, error) -> Void in
                    if !success {
                        Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
                    }
                    else {
                        Helper.PopupInformationBox(self, boxTitle: "Request Sent", message: "Please check your registered email account for resetting password")
                    }
                })
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
