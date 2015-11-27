//
//  WMSigninViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMSigninViewController: WMTextFieldViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var usernameTextField: WMDataInputTextField!
    @IBOutlet weak var passwordTextField: WMDataInputTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SignInBackground")!)
        
        // Set logo image view
        self.logoImageView.contentMode = .ScaleAspectFill //set contentMode to scale aspect to fit
        if let image = UIImage(named: "Logo") {
            self.logoImageView.image = image
        }
        
        // Set sign up button
        self.signUpButton.setTitleColor(UIColor.yellowColor(), forState: .Normal)
        
        // Set forgot password button
        self.forgotPasswordButton.setTitleColor(UIColor.yellowColor(), forState: .Normal)
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Get current user
        if User.currentUser() != nil {
            self.performSegueWithIdentifier("Directly Launch Main View", sender: self)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Launch Main View" || identifier == "Directly Launch Main View" {
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
                let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = UIAlertController(title: "Request Sent", message: "An email has been sent", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
