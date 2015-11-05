//
//  RegisterViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpScrollView: UIScrollView!
    @IBOutlet weak var userNameTextField: SignUpTextField!
    @IBOutlet weak var userPasswordTextField: SignUpTextField!
    @IBOutlet weak var userConfirmPasswordTextField: SignUpTextField!
    @IBOutlet weak var userEmailTextField: SignUpTextField!
    @IBOutlet weak var graduationYearTextField: SignUpTextField!
    @IBOutlet weak var signInLabel: HyperLinkTextView!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set current view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SignUpBackground")!)
        self.automaticallyAdjustsScrollViewInsets = true
        
        // Hide Back button on navigation controller
        //self.navigationItem.hidesBackButton = true
        
        // Set button layer
        signUpButton.layer.cornerRadius = 20; //half of the width
        
        // Set circular logo image view
        self.logoImageView.layer.borderWidth = 3.0
        self.logoImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2
        self.logoImageView.clipsToBounds = true

        // Setup scroll view
        self.signUpScrollView.scrollEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissInputView")
        self.signUpScrollView.addGestureRecognizer(tap)
        
        // Set left image icon for each text field
        self.setLeftImageViewForTextField(self.userNameTextField)
        self.setLeftImageViewForTextField(self.userPasswordTextField)
        self.setLeftImageViewForTextField(self.userConfirmPasswordTextField)
        self.setLeftImageViewForTextField(self.userEmailTextField)
        self.setLeftImageViewForTextField(self.graduationYearTextField)
        
        // Set Date Picker for graduationYearTextField
        let graduationYearPicker = GraduationYearPicker()
        graduationYearPicker.onYearSelected = { (year: Int) in
            if (year == 0) {
                self.graduationYearTextField.text = nil
            }
            else {
                self.graduationYearTextField.text = String(year)
            }
        }
        self.graduationYearTextField.inputView = graduationYearPicker
        self.graduationYearTextField.inputAccessoryView = inputToolBar(self.graduationYearTextField)
        
        // Set hyperlink labels
        self.signInLabel.text = ""
        self.signInLabel.hyperLinkActions = ["<si>": ["target": self, "selector": "redirectSignIn:"]]
        self.signInLabel.hyperLinkText = "Already has account? ##<si>Sign in"
    }
    
    // Dismiss inputView when touching any other areas on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissInputView()
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK:Actions
    @IBAction func signUp(sender: UIButton) {
        signUpUser()
    }
    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        dismissInputView()
    }
    
    //Calls this function when the tap is recognized to dismiss input view
    func dismissInputView() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        self.signUpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func redirectSignIn(sender: HyperLinkTextView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func signUpUser() -> Bool {
        
        var signUpSuccessed = true
 
        dismissInputView()
        
        self.user.validateUserWithBlock { (valid, error) -> Void in
            if (!valid) {
                let alert = UIAlertController(title: "Failed", message: "Invalid user information: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.showViewController(alert, sender: self)
            }
            signUpSuccessed = valid
        }
        if (!signUpSuccessed) { return false }
        
        self.user.signUpInBackgroundWithBlock { (success, error) -> Void in
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
            signUpSuccessed = success
        }
        if (!signUpSuccessed) { return false }
        
        return signUpSuccessed
    }
    
    // MARK:TextField delegates and functions
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        var error: String = ""
        
        // Validate input of each text field
        switch textField {
        case self.userNameTextField:
            self.user.username = textField.text
            if (self.user.username?.characters.count > 0) {
                user.validateUserName(&error)
            }
        case self.userPasswordTextField:
            self.user.password = textField.text
            if let confirmPassword = self.user.confirmPassword {
                if (confirmPassword.characters.count > 0) {
                    user.validateConfirmPassword(&error)
                    self.userConfirmPasswordTextField.setRightErrorViewForTextFieldWithErrorMessage(error)
                }
            }
            error = ""
            if (self.user.password!.characters.count > 0) {
                user.validateUserPassword(&error)
            }
        case self.userConfirmPasswordTextField:
            self.user.confirmPassword = textField.text
            if (self.user.confirmPassword!.characters.count > 0) {
                user.validateConfirmPassword(&error)
            }
        case self.userEmailTextField:
            self.user.email = textField.text
        case self.graduationYearTextField:
            if let graduationYear = self.graduationYearTextField.text {
                if (graduationYear.characters.count > 0) {
                    self.user.graduationYear = Int(graduationYear)!
                }
            }
        default:
             break
        }
        
        if let field = textField as? SignUpTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var offsetY: CGFloat = 0.0
        let previousTag = textField.tag - 1;
        // Try to find next responder
        if let previousTextField = textField.superview?.viewWithTag(previousTag) as? UITextField {
            offsetY = previousTextField.frame.origin.y
        }
        
        self.signUpScrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        
    }
    
    // Left view of text field is used to place specific icon
    func setLeftImageViewForTextField(textField: SignUpTextField) {
        var imageName = ""
        
        switch textField {
        case self.userNameTextField:
            imageName = "Name"
        case self.userPasswordTextField, self.userConfirmPasswordTextField:
            imageName = "Password"
        case self.userEmailTextField:
            imageName = "Email"
        case self.graduationYearTextField:
            imageName = "Grad"
        default:
            break;
        }
        
        textField.setLeftImageViewForTextField(UIImage(named: imageName))
    }
    
    // MARK:View components functions
    func inputToolBar(textField: UITextField) -> UIToolbar {
    
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolbar.barStyle = .Default;
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneToolButtonClicked:"))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }
}
