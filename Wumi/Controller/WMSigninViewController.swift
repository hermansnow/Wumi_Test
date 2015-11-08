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
    @IBOutlet weak var usernameTextField: WMDataInputTextField!
    @IBOutlet weak var passwordTextField: WMDataInputTextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SignInBackground")!)
        
        // Set logo image view
        self.logoImageView.contentMode = .ScaleAspectFill //set contentMode to scale aspect to fit
        if let image = UIImage(named: "Logo") {
            self.logoImageView.image = image
        }
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Launch Main View" {
            print(self.user)
            return self.user != nil
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
            self.user = User(pfUser: pfUser)
        }
    }
}
