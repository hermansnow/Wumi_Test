//
//  SignUpAccountViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpAccountViewController: ScrollTextFieldViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AvatarImageDelegate, DataInputTextFieldDelegate {
    // MARK: Properties
    
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
    
    // MARK: Life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set cancel button
        cancelButton.recommanded = false
        
        // Set avatar image delegates
        addAvatarImageView.delegate = self
        addAvatarImageView.image = Constants.SignIn.Image.AddAvatarImage
        
        // Set background views
        avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        
        // Set textfields
        passwordTextField.inputTextField.secureTextEntry = true
        confirmPasswordTextField.inputTextField.secureTextEntry = true
        
        // Set delegates
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw mask layer
        maskLayer.removeFromSuperlayer()
        let maskHeight = avatarBackgroundView.bounds.height * Constants.SignIn.Proportion.MaskHeightWithParentView
        let maskWidth = maskHeight * Constants.SignIn.Proportion.MaskWidthWithHeight
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight), cornerRadius: maskWidth / 2).CGPath
        maskLayer.position = CGPoint(x: (avatarBackgroundView.bounds.width - maskWidth) / 2, y: (avatarBackgroundView.bounds.height - maskHeight) / 2)
        avatarBackgroundView.layer.insertSublayer(maskLayer, below: addAvatarImageView.layer)
        
        // Redraw DataInput Text Field
        usernameTextField.drawUnderlineBorder()
        passwordTextField.drawUnderlineBorder()
        confirmPasswordTextField.drawUnderlineBorder()
        emailTextField.drawUnderlineBorder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Profile Form" {
            if let addProfileViewController = segue.destinationViewController as? AddProfileViewController {
                addProfileViewController.user = self.user
                addProfileViewController.avatarImage = newAvatarImage
            }
        }
    }
    
    // MARK:Actions
    
    @IBAction func signUpUser(sender: AnyObject) {
        dismissInputView()
        
        // Validate user inputs
        self.user.validateUser { (valid, error) -> Void in
            if !valid {
                Helper.PopupErrorAlert(self, errorMessage: "Invalid user information: \(error)")
                return
            }
            
            // Save avatar image file
            self.user.saveAvatarFile(self.newAvatarImage) { (saveImageSuccess, imageError) -> Void in
                if !saveImageSuccess {
                    Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    return
                }
                
                // Sign up user asynchronously
                self.user.signUpInBackgroundWithBlock { (signUpSuccess, signUpError) -> Void in
                    if !signUpSuccess {
                        Helper.PopupErrorAlert(self, errorMessage: "\(signUpError)")
                        return
                    }
                    
                    self.performSegueWithIdentifier("Show Profile Form", sender: self)
                }
            }
        }
    }
    
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
    
    // MARK: TextField delegates and functions
    
    func textFieldDidEndEditing(textField: UITextField) {
        var error: String = ""
        
        // Validate input of each text field
        switch textField {
        case usernameTextField.inputTextField:
            user.username = textField.text
            if user.username?.characters.count > 0 {
                user.validateUserName(&error)
                usernameTextField.errorText = error
            }
        case passwordTextField.inputTextField:
            user.password = textField.text
            if let confirmPassword = user.confirmPassword {
                if confirmPassword.characters.count > 0 {
                    user.validateConfirmPassword(&error)
                    confirmPasswordTextField.errorText = error
                }
            }
            error = ""
            if user.password!.characters.count > 0 {
                user.validateUserPassword(&error)
                passwordTextField.errorText = error
            }
        case confirmPasswordTextField.inputTextField:
            user.confirmPassword = textField.text
            if user.confirmPassword!.characters.count > 0 {
                user.validateConfirmPassword(&error)
                confirmPasswordTextField.errorText = error
            }
        case emailTextField.inputTextField:
            user.email = textField.text
        default:
            break
        }
    }
    
    // MARK: UIImagePicker delegates and functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let avatarImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.addAvatarImageView.image = avatarImage
                self.newAvatarImage = avatarImage   
            }
        }
    }
    
    // MARK: AvatarImageView delegates and functions
    
    func singleTap(imageView: AvatarImageView) {
        let addImageSheet = SelectPhotoActionSheet(title: Constants.SignIn.String.Alert.AddImageSheet.Title,
                                                 message: Constants.SignIn.String.Alert.AddImageSheet.Message,
                                          preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    // MARK: DataInputTextField delegates
    
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        dismissInputView()
    }
}
