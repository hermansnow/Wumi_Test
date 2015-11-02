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
        
        var userName = self.userName.text
        var userPassword = self.userPassword.text
        
        PFUser.logInWithUsernameInBackground(userName, password: userPassword) { (user, error) -> Void in
            if (user != nil) {
                var alert = UIAlertView(title: "Success", message: "Logged in", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                var alert = UIAlertView(title: "Failed", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
}
