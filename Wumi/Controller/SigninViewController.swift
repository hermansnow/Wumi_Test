//
//  SigninViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class SigninViewController: DataLoadingViewController {
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: DataInputTextField!
    @IBOutlet weak var passwordTextField: DataInputTextField!
    
    var forgotPasswordButton: TextLinkButton! // Forgot password button to be displayed if fails in login
    private lazy var maskLayer = CAShapeLayer() // Mask layer for logo
    
    // MARK: Lifecycle methods
    
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
        self.passwordTextField.inputTextField.secureTextEntry = true  // Securetext mode for password field
        self.usernameTextField.inputTextField.autocorrectionType = .No
        self.usernameTextField.inputTextField.tag = 1
        self.passwordTextField.inputTextField.tag = 2
        
        // Initialize forgotPassword Button
        self.forgotPasswordButton = TextLinkButton()
        self.forgotPasswordButton.textLinkFont = Constants.General.Font.ErrorFont
        self.forgotPasswordButton.setTitle(Constants.SignIn.String.forgotPasswordLink, forState: .Normal)
        self.forgotPasswordButton.addTarget(self, action: #selector(forgotPassword), forControlEvents: .TouchUpInside)
        self.forgotPasswordButton.hidden = true
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
        
        // Add delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
        
        // Fill in the username field if current user exists
        if let user = User.currentUser() {
            self.usernameTextField.text = user.username
            self.passwordTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissReachabilityError()
    }
    
    // All codes based on display frames should be called here after auto-layouting subviews
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
        self.usernameTextField.drawUnderlineBorder()
        self.passwordTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    // Sign in with username/ password filled in
    @IBAction func SignIn(sender: AnyObject) {
        guard let userName = usernameTextField.text, userPassword = passwordTextField.text else { return }
        
        self.showLoadingIndicator()
        User.logInWithUsernameInBackground(userName, password: userPassword) { (result, error) -> Void in
            guard let _ = result as? User else {
                self.passwordTextField.errorText = Constants.SignIn.String.ErrorMessages.incorrectPassword
                self.passwordTextField.actionHolder = self.forgotPasswordButton
                self.forgotPasswordButton.hidden = false
                self.hideLoadingIndicator()
                return
            }
            CDChatManager.sharedManager().openWithClientId(User.currentUser().objectId, callback: { (result: Bool, error: NSError!) -> Void in
                if (error == nil) {
                    self.performSegueWithIdentifier("Launch Main View", sender: self)
                }
                self.hideLoadingIndicator()
            })
        }
    }
    
    // Show a popup window to allow user request an email to reset password
    func forgotPassword() {
        Helper.PopupInputBox(self, boxTitle: Constants.SignIn.String.Alert.ResetPassword.Title,
                                    message: Constants.SignIn.String.Alert.ResetPassword.Message,
                             numberOfFileds: 1,
                                 textValues: [["placeHolder": "Email"]]) { (inputValues) -> Void in
                                    guard let email = inputValues.first! where email.characters.count == 0 else {
                                        return
                                    }
                                    
                                    User.requestPasswordResetForEmailInBackground(email) { (success, error) -> Void in
                                        if !success {
                                            Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                                        }
                                        else {
                                            Helper.PopupInformationBox(self, boxTitle: Constants.SignIn.String.Alert.ResetPasswordConfirm.Title,
                                                                                message: Constants.SignIn.String.Alert.ResetPasswordConfirm.Message)
                                        }
                                    }
                                }
    }
}

// MARK: UITextField delegate

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let nextResponder = textField.nextResponderTextField() else {
            textField.resignFirstResponder()
            return true
        }
        
        nextResponder.becomeFirstResponder()
        return false // Do not dismiss keyboard
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if self.passwordTextField.errorText != nil {
            self.passwordTextField.errorText = nil
            self.passwordTextField.actionHolder = nil
            self.forgotPasswordButton.hidden = true
        }
        
        return true
    }
}

// MARK: DataInputTextField delegate

extension SigninViewController: DataInputTextFieldDelegate { }
