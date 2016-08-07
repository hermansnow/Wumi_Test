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
        
        self.invitationCodeTextField.delegate = self
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set iniatial first responder
        invitationCodeTextField.inputTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissReachabilityError()
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
                Helper.PopupErrorAlert(self, errorMessage: "Invalid invitation code")
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

extension InvitationCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let nextResponder = textField.nextResponderTextField() else {
            textField.resignFirstResponder()
            return true
        }
        
        nextResponder.becomeFirstResponder()
        return false // Do not dismiss keyboard
    }
}

// MARK: DataInputTextField delegate

extension InvitationCodeViewController: DataInputTextFieldDelegate { }