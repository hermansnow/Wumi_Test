//
//  InvitationCodeViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class InvitationCodeViewController: DataLoadingViewController {
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var invitationCodeTextField: DataInputTextField!
    @IBOutlet weak var cancelButton: SystemButton!
    
    /// Invitation code for sign-up.
    private lazy var invitationCode = InvitationCode()
    /// Mask layer for logo view.
    private lazy var maskLayer = CAShapeLayer()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true,
                                                          animated: false)
        
        // Set up subview components
        self.setupLogoView()
        self.setupInputFields()
        self.setupButtons()
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
    }
    
    deinit {
        // Remove notification observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check network reachability
        self.checkReachability()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set iniatial first responder
        invitationCodeTextField.inputTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Dismiss network reachability error when view controller will disapear
        self.dismissReachabilityError()
    }
    
    /**
     - note:
     All codes based on display frames should be called here after auto-layouting subviews.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw mask layer
        let maskHeight = self.logoView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        self.maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                               y: 0,
                                                               width: maskWidth,
                                                               height: maskHeight),
                                           cornerRadius: maskWidth / 2).CGPath
        self.maskLayer.position = CGPoint(x: (self.logoView.bounds.width - maskWidth) / 2,
                                          y: (self.logoView.bounds.height - maskHeight) / 2)
        
        // Redraw DataInput Text Field
        invitationCodeTextField.drawUnderlineBorder()
    }
    
    // MARK: UI Functions
    
    /**
     Set up logo view.
     */
    private func setupLogoView() {
        // Set layout and colors
        self.logoView.layer.insertSublayer(self.maskLayer, below: self.logoImageView.layer)
        self.logoView.backgroundColor = Constants.General.Color.ThemeColor
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        
        // Add logo shadow
        self.logoImageView.layer.shadowColor = Constants.General.Color.ThemeColor.CGColor
        self.logoImageView.layer.shadowOffset = Constants.SignIn.Size.ShadowOffset
        self.logoImageView.layer.shadowOpacity = Constants.SignIn.Value.shadowOpacity
        self.logoImageView.layer.shadowRadius = Constants.SignIn.Value.shadowRadius
    }
    
    /**
     Set up input text fields for invitation form.
     */
    private func setupInputFields() {
        // Assign textfields' tag number
        self.invitationCodeTextField.inputTextField.tag = 1
        
        // Add delegates
        self.invitationCodeTextField.delegate = self
    }
    
    /**
     Set up buttons on invitation form.
     */
    private func setupButtons() {
        self.cancelButton.recommanded = false
    }
    
    /**
     Reset error information and handlers: remove error messages for all text fields, remove and hide error handlers.
     */
    private func resetError() {
        // Reset invitation text field
        self.invitationCodeTextField.cleanError()
    }
    
    // MARK: Actions
    
    /**
     Verify the invitation code filled in.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func verifyCode(sender: AnyObject) {
        // Dismiss all previous error messages
        self.resetError()
        
        // Show loading indicator once we start to verify invitation code from server
        self.showLoadingIndicator()
        
        self.invitationCode.invitationCode = self.invitationCodeTextField.text
        self.invitationCode.verifyCodeWhithBlock { (verified, error) in
            if !verified {
                if let wumiError = error where wumiError.type == .InvitationCode {
                    self.invitationCodeTextField.errorText = wumiError.error
                }
            }
            else {
                self.performSegueWithIdentifier("Show Sign Up Form", sender: self)
            }
            self.dismissLoadingIndicator()
        }
    }
    
    /**
     Return to sign-in view controller.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func ReturnSignIn(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
}

// MARK: UITextField delegate

extension InvitationCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let nextResponder = textField.nextResponderTextField() else {
            textField.resignFirstResponder()
            return true
        }
        
        nextResponder.becomeFirstResponder()
        return false // Do not dismiss keyboard
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.invitationCodeTextField.inputTextField {
            self.invitationCodeTextField.cleanError()
        }
        return true
    }
}

// MARK: DataInputTextField delegate

extension InvitationCodeViewController: DataInputTextFieldDelegate { }
