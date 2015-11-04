//
//  LogInViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LogInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var loginViewController: PFLogInViewController! = PFLogInViewController()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //if (PFUser.currentUser() == nil) {
            self.loginViewController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten, PFLogInFields.DismissButton]
            self.loginViewController.delegate = self
            self.loginViewController.signUpController?.delegate = self
            let logInLogoTitle = UILabel()
            logInLogoTitle.text = "Wumi"
            self.loginViewController.logInView?.logo = logInLogoTitle
        //}
    }
    
    // MARK: Parse Log In
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("Error in log in")
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func showParseUI(sender: UIButton) {
        self.presentViewController(self.loginViewController, animated: true, completion: nil)
        
    }
    
}
