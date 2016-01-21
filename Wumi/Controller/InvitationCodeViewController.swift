//
//  WMInvitationCodeViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMInvitationCodeViewController: WMRegisterViewController {
    
    @IBOutlet weak var invitationCodeTextField: DataInputTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInLabel: WMHyperLinkTextView!

    var invitationCode = InvitationCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title label
        self.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set hyperlink labels
        self.signInLabel.hyperLinkActions = ["<SignIn>": ["target": self, "selector": "redirectSignIn:"]]
        self.signInLabel.hyperLinkText = "Already has an account? ##<SignIn>Sign in"
        self.signInLabel.parseHyperLinkText()
    }
    
    // MARK: Actions
    @IBAction func verifyCode(sender: AnyObject) {
        self.invitationCode.invitationCode = self.invitationCodeTextField.text
        self.invitationCode.verifyCodeWhithBlock({ (verified) -> Void in
            if !verified {
                let alert = UIAlertController(title: "Failed", message: "Invalid invitation code", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("Show New Account Form", sender: self)
            }
        })
    }
    
    func redirectSignIn(sender: WMHyperLinkTextView) {
        self.navigationController?.popToRootViewControllerAnimated(true) // The root view controller is designed to be the Sign In View Controller
    }
}
