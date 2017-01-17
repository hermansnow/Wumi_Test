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
    
    /// Forgot password button to be displayed if fails in login.
    private lazy var forgotPasswordButton = TextLinkButton()
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
        self.setupForgotPasswordButton()
        
        // Add notification observer
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
        
        // Fill in the username field if current user exists in cache
        if let user = User.currentUser() {
            self.usernameTextField.text = user.username
            self.passwordTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
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
        self.usernameTextField.drawUnderlineBorder()
        self.passwordTextField.drawUnderlineBorder()
    }
    
    // MARK: UI Functions
    
    /**
     Set up logo view.
     */
    private func setupLogoView() {
        // Set layout and colors
        self.logoView.backgroundColor = Constants.General.Color.ThemeColor
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        self.logoView.layer.insertSublayer(self.maskLayer,
                                           below: self.logoImageView.layer)
        
        // Set logo image view
        self.logoImageView.layer.shadowColor = Constants.General.Color.ThemeColor.CGColor
        self.logoImageView.layer.shadowOffset = Constants.SignIn.Size.ShadowOffset
        self.logoImageView.layer.shadowOpacity = Constants.SignIn.Value.shadowOpacity
        self.logoImageView.layer.shadowRadius = Constants.SignIn.Value.shadowRadius
    }
    
    /**
     Set up input text fields for sign in form.
     */
    private func setupInputFields() {
        // Set text fields' properties
        self.passwordTextField.inputTextField.secureTextEntry = true  // Securetext mode for password field
        self.usernameTextField.inputTextField.autocorrectionType = .No  // No auto correctiion for username input
        
        // Assign textfields' tag number
        self.usernameTextField.inputTextField.tag = 1
        self.passwordTextField.inputTextField.tag = 2
        
        // Add delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    /**
     Set up forgot password button.
     */
    private func setupForgotPasswordButton() {
        self.forgotPasswordButton.textLinkFont = Constants.General.Font.ErrorFont
        self.forgotPasswordButton.setTitle(Constants.SignIn.String.forgotPasswordLink,
                                           forState: .Normal)
        self.forgotPasswordButton.addTarget(self,
                                            action: #selector(self.forgotPassword),
                                            forControlEvents: .TouchUpInside)
        self.forgotPasswordButton.hidden = true // Hide it as initial
    }
    
    /**
     Reset error information and handlers: remove error messages for all text fields, remove and hide error handlers.
     */
    private func resetAllError() {
        // Reset username text field
        self.usernameTextField.cleanError()
        
        // Reset password text field
        self.passwordTextField.cleanError()
        self.forgotPasswordButton.hidden = true
    }
    
    // MARK: Actions
    
    /**
     Action when end-user clicks "Sign In" button. 
     View controller will try to sign in with username and password filled in.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func SignIn(sender: AnyObject) {
        // Dismiss all previous error messages
        self.resetAllError()
        
        // Check username
        guard let userName = usernameTextField.text where userName.characters.count > 0 else {
            self.usernameTextField.errorText = Constants.SignIn.String.ErrorMessages.blankUsername
            return
        }
        // Check password
        guard let userPassword = passwordTextField.text where userPassword.characters.count > 0 else {
            self.passwordTextField.errorText = Constants.SignIn.String.ErrorMessages.blankPassword
            return
        }
        
        // Show loading indicator once we start to login with server
        self.showLoadingIndicator()
        
        User.logInWithUsernameInBackground(userName,
                                           password: userPassword) { (result, error) in
            guard let _ = result as? User else {
                self.passwordTextField.errorText = Constants.SignIn.String.ErrorMessages.incorrectPassword
                self.passwordTextField.actionView = self.forgotPasswordButton
                self.forgotPasswordButton.hidden = false
                self.dismissLoadingIndicator()
                return
            }
            CDChatManager.sharedManager().openWithClientId(User.currentUser().objectId, callback: { (result: Bool, error: NSError!) -> Void in
                if (error == nil) {
                    self.performSegueWithIdentifier("Launch Main View", sender: self)
                }
                self.dismissLoadingIndicator()
            })
        }
    }
    
    /**
     Prompt user to enter his registered email to reset password.
     */
    func forgotPassword() {
        // Pop up an input box for end-users to entering registered email
        Helper.PopupInputBox(self,
                             boxTitle: Constants.SignIn.String.Alert.ResetPassword.Title,
                             message: Constants.SignIn.String.Alert.ResetPassword.Message,
                             numberOfFileds: 1,
                             textValues: [["placeHolder": "Email"]]) { (inputValues) in
                                guard let email = inputValues.first! where !email.isEmpty else { return }
                                    
                                User.requestPasswordResetForEmailInBackground(email) { (success, error) in
                                    guard success else {
                                        ErrorHandler.popupErrorAlert(self, errorMessage: "\(error)")
                                        return
                                    }
                                        
                                    Helper.PopupInformationBox(self,
                                                               boxTitle: Constants.SignIn.String.Alert.ResetPasswordConfirm.Title,
                                                               message: Constants.SignIn.String.Alert.ResetPasswordConfirm.Message)
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
        if textField == self.usernameTextField.inputTextField {
            self.usernameTextField.cleanError()
            // Clean password error also if current error is invalid username/password
            if let error = self.passwordTextField.errorText where error == Constants.SignIn.String.ErrorMessages.incorrectPassword {
                self.passwordTextField.cleanError()
                self.forgotPasswordButton.hidden = true
            }
        }
        else if textField == self.passwordTextField.inputTextField {
            self.passwordTextField.cleanError()
            self.forgotPasswordButton.hidden = true
        }
        return true
    }
}

// MARK: DataInputTextField delegate

extension SigninViewController: DataInputTextFieldDelegate { }
