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
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Get current user
        if let user = User.currentUser() {
            if user.objectId != nil {
                performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = User.currentUser() {
            usernameTextField.text = user.username
        }
    }
    
    // MARK: Actions
    @IBAction func SignIn(sender: AnyObject) {
        
        let userName = usernameTextField.text
        let userPassword = passwordTextField.text
        
        User.logInWithUsernameInBackground(userName!, password: userPassword!) { (pfUser, error) -> Void in
            if pfUser == nil {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                self.performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
    }
    
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
