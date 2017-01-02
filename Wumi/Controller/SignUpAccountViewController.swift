//
//  SignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class SignUpAccountViewController: ScrollTextFieldViewController {
    
    @IBOutlet weak var avatarBackgroundView: ColorGradientView!
    @IBOutlet weak var addAvatarImageView: AvatarImageView!
    @IBOutlet weak var usernameTextField: DataInputTextField!
    @IBOutlet weak var passwordTextField: DataInputTextField!
    @IBOutlet weak var confirmPasswordTextField: DataInputTextField!
    @IBOutlet weak var emailTextField: DataInputTextField!
    @IBOutlet weak var cancelButton: SystemButton!
    
    /// Mask layer for logo view.
    private lazy var maskLayer = CAShapeLayer()
    
    /// Avatart image for this new user's profile.
    private var newAvatarImage: UIImage?
    /// User object will be signed up.
    private lazy var user = User()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true,
                                                          animated: false)
        
        // Set up subview components
        self.setupAvatarView()
        self.setupInputFields()
        self.setupButtons()
    }
    
    /**
     - note:
     All codes based on display frames should be called here after auto-layouting subviews.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw mask layer
        let maskHeight = self.avatarBackgroundView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        self.maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                               y: 0,
                                                               width: maskWidth,
                                                               height: maskHeight),
                                          cornerRadius: maskWidth / 2).CGPath
        self.maskLayer.position = CGPoint(x: (self.avatarBackgroundView.bounds.width - maskWidth) / 2,
                                          y: (self.avatarBackgroundView.bounds.height - maskHeight) / 2)
        
        // Redraw DataInput Text Field
        self.usernameTextField.drawUnderlineBorder()
        self.passwordTextField.drawUnderlineBorder()
        self.confirmPasswordTextField.drawUnderlineBorder()
        self.emailTextField.drawUnderlineBorder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue for showing addtional profile view controller
        if let addProfileViewController = segue.destinationViewController as? AddProfileViewController where segue.identifier == "Add Profile" {
            addProfileViewController.user = self.user // pass down the new user we just signed up
            addProfileViewController.avatarImage = self.newAvatarImage // pass avatar image to improve performance, so we do not need to load it from server
        }
    }
    
    // MARK: UI Functions
    
    /**
     Set up avatar selector view.
     */
    private func setupAvatarView() {
        // Set avatar view
        self.addAvatarImageView.backgroundColor = Constants.General.Color.ThemeColor
        self.addAvatarImageView.image = Constants.SignIn.Image.AddAvatarImage
        
        // Set background views
        self.avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        
        // Add avatar view mask
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        self.avatarBackgroundView.layer.insertSublayer(self.maskLayer,
                                                       below: self.addAvatarImageView.layer)
    }
    
    /**
     Set up input text fields for signup form.
     */
    private func setupInputFields() {
        // Set password textfields
        self.usernameTextField.inputTextField.autocorrectionType = .No  // No auto correctiion for username input
        self.passwordTextField.inputTextField.secureTextEntry = true
        self.confirmPasswordTextField.inputTextField.secureTextEntry = true
        self.emailTextField.inputTextField.keyboardType = .EmailAddress
        
        // Set textfields' tag number
        self.usernameTextField.inputTextField.tag = 1
        self.passwordTextField.inputTextField.tag = 2
        self.confirmPasswordTextField.inputTextField.tag = 3
        self.emailTextField.inputTextField.tag = 4
        
        // Set delegates
        self.addAvatarImageView.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    /**
     Set up buttons on signup form.
     */
    private func setupButtons() {
        self.cancelButton.recommanded = false
    }
    
    /**
     Reset error information and handlers: remove error messages for all text fields, remove and hide error handlers.
     */
    private func resetAllError() {
        self.usernameTextField.cleanError()
        self.passwordTextField.cleanError()
        self.confirmPasswordTextField.cleanError()
        self.emailTextField.cleanError()
    }
    
    /**
     Show errors under specific text fields.
     
     - Parameters:
        - errors: a dictionary includes error messages for the following type of errors: 
     */
    private func showErrors(errors: [WumiError]) {
        // Show error message to correctly text field
        for error in errors {
            guard let errorMessage = error.error else { continue }
            
            switch error.type {
            case .Name:
                self.usernameTextField.errorText = errorMessage
            case .Password:
                self.passwordTextField.errorText = errorMessage
            case .ConfirmPassword:
                self.confirmPasswordTextField.errorText = errorMessage
            case .Email:
                self.emailTextField.errorText = errorMessage
            default:
                ErrorHandler.popupErrorAlert(self, errorMessage: errorMessage)
                break
            }
        }
    }
    
    // MARK:Actions
    
    /**
     Sign up user filled in.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func signUpUser(sender: AnyObject) {
        // End editing mode
        self.view.endEditing(true)
        
        // Dismiss all previous error messages
        self.resetAllError()
        
        // Show loading indicator once we start to verify invitation code from server
        self.showLoadingIndicator()
        
        // Validate user inputs asychronously
        self.user.validateUser { (valid, errors) -> Void in
            guard valid else {
                // Show error message to correctly text field
                self.showErrors(errors)
                self.dismissLoadingIndicator()
                return
            }
            
            // Save avatar image file asynchronously
            self.user.saveAvatarFile(self.newAvatarImage) { (saveImageSuccess, imageError) -> Void in
                guard saveImageSuccess else {
                    if let error = imageError where error.type == .Image {
                        ErrorHandler.popupErrorAlert(self, errorMessage: error.error)
                    }
                    self.dismissLoadingIndicator()
                    return
                }
                
                // Sign up user asynchronously
                self.user.signUpInBackgroundWithBlock { (signUpSuccess, signUpError) -> Void in
                    guard signUpSuccess else {
                        if let error = ErrorHandler.parseError(signUpError) {
                            self.showErrors([error])
                        }
                        self.dismissLoadingIndicator()
                        return
                    }
                    
                    self.performSegueWithIdentifier("Add Profile", sender: self)
                    self.dismissLoadingIndicator()
                }
            }
        }
    }
    
    /**
     Cancel the signup process, back to the sign in view controller.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func cancel(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
}

// MARK: UITextField delegate
    
extension SignUpAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        /// Validation error message string
        var error = ""

        // Handle input of each text field
        switch textField {
        case self.usernameTextField.inputTextField:
            guard let username = textField.text where username.characters.count > 0 else { break } // do not show error for blank in this case
            
            self.user.username = username
            self.user.validateUserName(&error)
            self.usernameTextField.errorText = error
            
        case self.passwordTextField.inputTextField:
            guard let password = textField.text where password.characters.count > 0 else { break } // do not show error for blank in this case
            
            self.user.password = password
            self.user.validatePassword(&error)
            self.passwordTextField.errorText = error
            
            // Compare with confirmed password
            guard let confirmPassword = self.user.confirmPassword where confirmPassword.characters.count > 0 else { break } // do not show error for blank in this case
            
            self.user.validateConfirmPassword(&error)
            self.confirmPasswordTextField.errorText = error
            
        case self.confirmPasswordTextField.inputTextField:
            guard let confirmPassword = textField.text where confirmPassword.characters.count > 0 else { break } // do not show error for blank in this case
            
            self.user.confirmPassword = confirmPassword
            self.user.validateConfirmPassword(&error)
            self.confirmPasswordTextField.errorText = error
            
        case self.emailTextField.inputTextField:
            self.user.email = textField.text
        default:
            break
        }
    }
    
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
        }
        else if textField == self.passwordTextField.inputTextField {
            self.passwordTextField.cleanError()
            // Clean confirmed password error also if current error is confirmed password mismarch
            if let error = self.confirmPasswordTextField.errorText where error == Constants.SignIn.String.ErrorMessages.passwordNotMatch {
                self.confirmPasswordTextField.cleanError()
            }
        }
        else if textField == self.confirmPasswordTextField.inputTextField {
            self.confirmPasswordTextField.cleanError()
        }
        else if textField == self.emailTextField.inputTextField {
            self.emailTextField.cleanError()
        }
        return true
    }
}

// MARK: AvatarImageView delegate

extension SignUpAccountViewController: AvatarImageDelegate, UINavigationControllerDelegate {
    func singleTap(imageView: AvatarImageView) {
        let picker = SelectPhotoActionSheet()
        picker.cropImage = true
        picker.delegate = self
        
        presentViewController(picker, animated: true, completion: nil)
    }
}

// MARK: UIImagePicker delegate

extension SignUpAccountViewController: SelectPhotoActionSheetDelegate {
    func selectPhotoActionSheet(controller: SelectPhotoActionSheet, didFinishePickingPhotos images: [UIImage], assets: [PHAsset]?, sourceType: UIImagePickerControllerSourceType) {
        guard let avatarImage = images.first else { return }
        
        self.addAvatarImageView.image = avatarImage
        self.newAvatarImage = avatarImage
    }
}

// MARK: DataInputTextField delegate

extension SignUpAccountViewController: DataInputTextFieldDelegate { }
