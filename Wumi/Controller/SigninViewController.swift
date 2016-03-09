//
//  SigninViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: DataInputTextField!
    @IBOutlet weak var passwordTextField: DataInputTextField!
    
    var forgotPasswordButton: TextLinkButton!
    private lazy var maskLayer = CAShapeLayer()
    
    // MARK: Life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set layout and colors
        logoView.backgroundColor = Constants.General.Color.ThemeColor
        maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        
        // Set logo shadow
        let logoLayer = logoImageView.layer
        logoLayer.shadowColor = Constants.General.Color.ThemeColor.CGColor
        logoLayer.shadowOffset = Constants.SignIn.Size.ShadowOffset
        logoLayer.shadowOpacity = Constants.SignIn.Value.shadowOpacity
        logoLayer.shadowRadius = Constants.SignIn.Value.shadowRadius
        
        // Set text fields
        passwordTextField.inputTextField.secureTextEntry = true
        
        // Initialize forgotPassword Button
        forgotPasswordButton = TextLinkButton()
        forgotPasswordButton.textLinkFont = Constants.General.Font.ErrorFont
        forgotPasswordButton.setTitle(Constants.SignIn.String.forgotPasswordLink, forState: .Normal)
        forgotPasswordButton.addTarget(self, action: Selector("forgotPassword"), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fill in the username field if current user exists
        if let user = User.currentUser() {
            usernameTextField.text = user.username
            passwordTextField.becomeFirstResponder()
        }
    }
    
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw mask layer
        maskLayer.removeFromSuperlayer()
        let maskHeight = logoView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight), cornerRadius: maskWidth / 2).CGPath
        maskLayer.position = CGPoint(x: (logoView.bounds.width - maskWidth) / 2, y: (logoView.bounds.height - maskHeight) / 2)
        logoView.layer.insertSublayer(maskLayer, below: logoImageView.layer)
        
        // Redraw DataInput Text Field
        usernameTextField.drawUnderlineBorder()
        passwordTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    // Sign in with username/ password filled in
    @IBAction func SignIn(sender: AnyObject) {
        let userName = usernameTextField.text
        let userPassword = passwordTextField.text
        
        User.logInWithUsernameInBackground(userName!, password: userPassword!) { (pfUser, error) -> Void in
            if pfUser == nil {
                self.passwordTextField.errorText = Constants.SignIn.String.ErrorMessages.incorrectPassword
                self.passwordTextField.actionHolder = self.forgotPasswordButton
                
                //Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                self.performSegueWithIdentifier("Launch Main View", sender: self)
            }
        }
    }
    
    // Show a popup window to allow user request an email to reset password
    func forgotPassword() {
        Helper.PopupInputBox(self, boxTitle: Constants.SignIn.String.Alert.ResetPassword.Title,
                                    message: Constants.SignIn.String.Alert.ResetPassword.Message,
                             numberOfFileds: 1,
                                 textValues: [["placeHolder": "Email"]]) { (inputValues) -> Void in
                                    if let email = inputValues.first! {
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
}
