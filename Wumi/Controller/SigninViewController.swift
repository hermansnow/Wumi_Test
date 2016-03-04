//
//  SigninViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoBorderLayerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: DataInputTextField!
    @IBOutlet weak var passwordTextField: DataInputTextField!
    var forgotPasswordButton: TextLinkButton!
    
    // MARK: Life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Get current user
        if let user = User.currentUser() {
            if user.objectId != nil {
                user.fetchInBackgroundWithBlock(nil)
                performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
        
        // Set layout and colors
        logoView.backgroundColor = Constants.UI.Color.ThemeColor
        logoBorderLayerView.backgroundColor = UIColor.whiteColor()
        logoBorderLayerView.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Set logo shadow
        let logoLayer = logoImageView.layer
        logoLayer.shadowColor = Constants.UI.Color.ThemeColor.CGColor
        logoLayer.shadowOffset = CGSize(width: 0, height: 2)
        logoLayer.shadowOpacity = 1
        logoLayer.shadowRadius = 3
        
        // Set text fields
        passwordTextField.inputTextField.secureTextEntry = true
        
        // Initialize forgotPassword Button
        forgotPasswordButton = TextLinkButton()
        forgotPasswordButton.setTitle("Forgot password?", forState: .Normal)
        forgotPasswordButton.addTarget(self, action: Selector("forgotPassword:"), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fill in the username field if current user exists
        if let user = User.currentUser() {
            usernameTextField.text = user.username
        }
    }
    
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set circular logo image view
        logoBorderLayerView.layer.cornerRadius = logoBorderLayerView.frame.size.width / 2
        logoBorderLayerView.clipsToBounds = true
        
        // Redraw DataInput Text Field
        usernameTextField.drawUnderlineBorder()
        passwordTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    // Sign in with username/ password filled in
    @IBAction func SignIn(sender: AnyObject) {
        let userName = usernameTextField.text
        let userPassword = passwordTextField.text
        
        User.logInWithUsernameInBackground(userName!, password: userPassword!) { (pfUser, error) -> Void in
            if pfUser == nil {
                self.passwordTextField.errorText = "Incorrect password"
                self.passwordTextField.actionHolder = self.forgotPasswordButton
                
                //Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                self.performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
    }
    
    // Show a popup window to allow user request an email to reset password
    @IBAction func forgotPassword(sender: AnyObject) {
        Helper.PopupInputBox(self, boxTitle: "Reset Password", message: "Please enter the email address for your account",
            numberOfFileds: 1, textValues: [["placeHolder": "Email"]]) { (inputValues) -> Void in
                if let email = inputValues.first! {
                    User.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
                        if !success {
                            Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                        }
                        else {
                            Helper.PopupInformationBox(self, boxTitle: "Request Sent", message: "Please check your registered email account for resetting password")
                        }
                    })
                }

        }
    }
}
