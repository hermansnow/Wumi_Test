//
//  CustomLoginViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Parse

class CustomLoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBAction func logIn(sender: AnyObject) {
        
        let userName = self.userName.text
        let userPassword = self.userPassword.text
        
        User.logInWithUsernameInBackground(userName!, password: userPassword!) { (user, error) -> Void in
            if (user != nil) {
                let alert = UIAlertView(title: "Success", message: "Logged in", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                let alert = UIAlertView(title: "Failed", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
}
