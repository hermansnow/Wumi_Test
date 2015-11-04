//
//  RegisterViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userConfirmPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userInviteCodeTextField: UITextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLeftImageViewForTextField(self.userNameTextField)
        self.setLeftImageViewForTextField(self.userPasswordTextField)
        self.setLeftImageViewForTextField(self.userConfirmPasswordTextField)
        self.setLeftImageViewForTextField(self.userEmailTextField)
        self.setLeftImageViewForTextField(self.userInviteCodeTextField)
    }
    
    func setLeftImageViewForTextField(textField: UITextField) -> Void {
        var imageName = ""
        var leftImageView: UIImageView = UIImageView()
        
        switch textField {
        case self.userNameTextField:
            imageName = "Name"
        case self.userPasswordTextField, self.userConfirmPasswordTextField:
            imageName = "Password"
        case self.userEmailTextField:
            imageName = "Email"
        default:
            break;
        }
        
        if (imageName.characters.count > 0) {
            leftImageView = UIImageView(image: UIImage(named: imageName))
            leftImageView.frame = CGRectMake(0, 0, 30, textField.bounds.height)
            textField.leftView = leftImageView
            textField.leftViewMode = UITextFieldViewMode.Always
        }
    }
    
    // MARK:Actions
    @IBAction func Cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: UIButton) {
        signUpUser()
    }
    
    // MARK:TextField Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
            signUpUser()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.resetTextField(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case self.userNameTextField:
            self.user.username = textField.text
            var error = ""
            if (!user.validateUserName(&error)) {
                self.highlightInvalidTextField(textField, error: error)
            }
        case self.userPasswordTextField:
            self.user.password = textField.text
            var error = ""
            if (!user.validateUserPassword(&error)) {
                self.highlightInvalidTextField(textField, error: error)
            }
        case self.userEmailTextField:
            self.user.email = textField.text
        default:
             break
        }
    }
    
    func resetTextField(textField: UITextField) {
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.grayColor().CGColor;
    }
    
    func highlightInvalidTextField(textField: UITextField, error: String) {
        
        //highlightTextField in red
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.redColor().CGColor;
        
        //rounded corners
        //textField.layer.cornerRadius = 5;
        //textField.clipsToBounds = true;
        
        //Log error
        print("\(error)")
    }
    
    //# functions
    func signUpUser() -> Bool {
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.showViewController(alert, sender: self)
                })
            }
            else {
                let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.showViewController(alert, sender: self)
            }
        }
    
        return true;
    }
    

}
