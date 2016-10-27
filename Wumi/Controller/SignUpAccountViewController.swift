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
    
    var newAvatarImage: UIImage?
    lazy var user = User()
    private lazy var maskLayer = CAShapeLayer()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set avatar view
        self.addAvatarImageView.backgroundColor = Constants.General.Color.ThemeColor
        self.addAvatarImageView.image = Constants.SignIn.Image.AddAvatarImage
        
        // Set background views
        self.avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        
        // Add avatar view mask
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        self.avatarBackgroundView.layer.insertSublayer(self.maskLayer, below: self.addAvatarImageView.layer)
        
        // Set textfields
        self.passwordTextField.inputTextField.secureTextEntry = true
        self.confirmPasswordTextField.inputTextField.secureTextEntry = true
        self.usernameTextField.inputTextField.tag = 1
        self.passwordTextField.inputTextField.tag = 2
        self.confirmPasswordTextField.inputTextField.tag = 3
        self.emailTextField.inputTextField.tag = 4
        
        // Set cancel button
        self.cancelButton.recommanded = false
        
        // Set delegates
        self.addAvatarImageView.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw mask layer
        let maskHeight = self.avatarBackgroundView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        self.maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight),
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
        if let addProfileViewController = segue.destinationViewController as? AddProfileViewController where segue.identifier == "Add Profile" {
            addProfileViewController.user = self.user
            addProfileViewController.avatarImage = self.newAvatarImage
        }
    }
    
    // MARK:Actions
    
    @IBAction func signUpUser(sender: AnyObject) {
        // Validate user inputs
        self.showLoadingIndicator()
        self.user.validateUser { (valid, error) -> Void in
            guard valid else {
                Helper.PopupErrorAlert(self, errorMessage: "Invalid user information: \(error)")
                self.hideLoadingIndicator()
                return
            }
            
            // Save avatar image file
            self.user.saveAvatarFile(self.newAvatarImage) { (saveImageSuccess, imageError) -> Void in
                guard saveImageSuccess else {
                    Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    self.hideLoadingIndicator()
                    return
                }
                
                // Sign up user asynchronously
                self.user.signUpInBackgroundWithBlock { (signUpSuccess, signUpError) -> Void in
                    guard signUpSuccess else {
                        Helper.PopupErrorAlert(self, errorMessage: "\(signUpError)")
                        self.hideLoadingIndicator()
                        return
                    }
                    self.performSegueWithIdentifier("Add Profile", sender: self)
                    self.hideLoadingIndicator()
                }
            }
        }
    }
    
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
}

// MARK: UITextField delegate
    
extension SignUpAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        var error = ""
        
        // Validate input of each text field
        switch textField {
        case self.usernameTextField.inputTextField:
            guard let username = textField.text where username.characters.count > 0 else { break }
            self.user.username = username
            self.user.validateUserName(&error)
            self.usernameTextField.errorText = error
            
        case self.passwordTextField.inputTextField:
            guard let password = textField.text where password.characters.count > 0 else { break }
            self.user.password = password
            self.user.validateUserPassword(&error)
            self.passwordTextField.errorText = error
            
            // Compare with inputted confirm password
            guard let confirmPassword = self.user.confirmPassword where confirmPassword.characters.count > 0 else { break }
            self.user.validateConfirmPassword(&error)
            self.confirmPasswordTextField.errorText = error
            
        case self.confirmPasswordTextField.inputTextField:
            self.user.confirmPassword = textField.text
            if self.user.confirmPassword!.characters.count > 0 {
                self.user.validateConfirmPassword(&error)
                self.confirmPasswordTextField.errorText = error
            }
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

// MARK: DataInputTextField delegate

extension SignUpAccountViewController: DataInputTextFieldDelegate {
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
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
