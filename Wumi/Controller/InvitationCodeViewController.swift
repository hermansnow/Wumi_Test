//
//  InvitationCodeViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class InvitationCodeViewController: RegisterViewController {
    
    @IBOutlet weak var invitationCodeTextField: SignUpTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInLabel: HyperLinkTextView!

    var invitationCode = InvitationCode()
    var verified = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title label
        self.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set hyperlink labels
        self.signInLabel.hyperLinkActions = ["<si>": ["target": self, "selector": "redirectSignIn:"]]
        self.signInLabel.hyperLinkText = "Already has account? ##<si>Sign in"
        self.signInLabel.parseHyperLinkText()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Next To New Account" {
            return self.verified
        }
        return true
    }
    
    
    // MARK: Actions
    override func finishForm() {
        self.invitationCode.invitationCode = self.invitationCodeTextField.text
        self.invitationCode.verifyCodeWhithBlock({ (verified) -> Void in
            if !verified {
                let alert = UIAlertController(title: "Failed", message: "Invalid invitation code", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.verified = verified
        })
    }
    
    func redirectSignIn(sender: HyperLinkTextView) {
        self.navigationController?.popToRootViewControllerAnimated(true) // The root view controller is designed to be the Sign In View Controller
    }
}
