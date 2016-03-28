//
//  InvitationCodeViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class InvitationCodeViewController: UIViewController {
    
    @IBOutlet weak var invitationCodeTextField: DataInputTextField!

    var invitationCode = InvitationCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Set iniatial first responder
        invitationCodeTextField.inputTextField.becomeFirstResponder()
    }
    
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw DataInput Text Field
        invitationCodeTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    @IBAction func verifyCode(sender: AnyObject) {
        invitationCode.invitationCode = invitationCodeTextField.text
        invitationCode.verifyCodeWhithBlock({ (verified) -> Void in
            if !verified {
                Helper.PopupErrorAlert(self, errorMessage: "Invalid invitation code", block: nil)
            }
            else {
                self.performSegueWithIdentifier("Show New Account Form", sender: self)
            }
        })
    }
    
    @IBAction func ReturnSignIn(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
}
