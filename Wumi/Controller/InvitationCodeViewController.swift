//
//  InvitationCodeViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class InvitationCodeViewController: UIViewController {
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var invitationCodeTextField: DataInputTextField!
    @IBOutlet weak var cancelButton: SystemButton!

    var invitationCode = InvitationCode()
    private lazy var maskLayer = CAShapeLayer() // Mask layer for logo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set layout and colors
        self.logoView.layer.insertSublayer(self.maskLayer, below: self.logoImageView.layer)
        self.logoView.backgroundColor = Constants.General.Color.ThemeColor
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        
        // Add logo shadow
        self.logoImageView.layer.shadowColor = Constants.General.Color.ThemeColor.CGColor
        self.logoImageView.layer.shadowOffset = Constants.SignIn.Size.ShadowOffset
        self.logoImageView.layer.shadowOpacity = Constants.SignIn.Value.shadowOpacity
        self.logoImageView.layer.shadowRadius = Constants.SignIn.Value.shadowRadius
        
        // Set text fields
        self.invitationCodeTextField.inputTextField.tag = 1
        
        // Set cancel button
        self.cancelButton.recommanded = false
        
        // Add delegates
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
        
        // Redraw mask layer
        let maskHeight = self.logoView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        self.maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight),
                                           cornerRadius: maskWidth / 2).CGPath
        self.maskLayer.position = CGPoint(x: (self.logoView.bounds.width - maskWidth) / 2,
                                          y: (self.logoView.bounds.height - maskHeight) / 2)
        
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