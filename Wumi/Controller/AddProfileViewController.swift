//
//  AddProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class AddProfileViewController: ScrollTextFieldViewController {
    
    @IBOutlet weak var avatarBackgroundView: ColorGradientView!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var nameTextField: DataInputTextField!
    @IBOutlet weak var graduationYearTextField: DataInputTextField!
    @IBOutlet weak var skipButton: SystemButton!
    
    /// Mask layer for logo view.
    private lazy var maskLayer = CAShapeLayer()
    
    /// Avatart image for this new user's profile.
    var avatarImage: UIImage?
    /// User object just signed up.
    var user: User = User()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up subview components
        self.setupAvatarView()
        self.setupGraduationYearPicker()
        self.setupInputFields()
        self.setupButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Set iniatial first responder
        self.nameTextField.inputTextField.becomeFirstResponder()
    }
    
    // All codes based on display frames should be called here after layouting subviews
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
        self.nameTextField.drawUnderlineBorder()
        self.graduationYearTextField.drawUnderlineBorder()
    }
    
    // MARK: UI Functions
    
    /**
     Set up avatar selector view.
     */
    private func setupAvatarView() {
        // Set avatar image
        self.avatarImageView.image = avatarImage ?? UIImage(named: Constants.General.ImageName.AnonymousAvatar)
        
        // Set background views
        self.avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        
        // Add avatar view mask
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        self.avatarBackgroundView.layer.insertSublayer(self.maskLayer, below: self.avatarImageView.layer)
    }
    
    /**
     Set up graduation year picker.
     */
    private func setupGraduationYearPicker() {
        let graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0,
                                                                                              y: view.frame.height / 3 * 2),
                                                                              size: CGSize(width: view.frame.width,
                                                                                           height: view.frame.height / 3)))
        self.graduationYearTextField.inputTextField.inputView = graduationYearPickerView
        
        // Add delegate
        graduationYearPickerView.launchTextField = self.graduationYearTextField.inputTextField
        graduationYearPickerView.delegate = self
    }
    
    /**
     Set up input text fields for signup form.
     */
    private func setupInputFields() {
        // Set textfields
        self.nameTextField.inputTextField.autocapitalizationType = .Words
        
        // Set textfields' tag number
        self.nameTextField.inputTextField.tag = 1
        self.graduationYearTextField.inputTextField.tag = 2
        
        // Set delegates
        self.nameTextField.delegate = self
        self.graduationYearTextField.delegate = self
    }
    
    /**
     Set up buttons on signup form.
     */
    private func setupButtons() {
        self.skipButton.recommanded = false
    }
    
    /**
     Reset error information and handlers: remove error messages for all text fields, remove and hide error handlers.
     */
    private func resetAllError() {
        self.nameTextField.cleanError()
        self.graduationYearTextField.cleanError()
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
            case .DisplayName:
                self.nameTextField.errorText = errorMessage
            case .GraduationYear:
                self.graduationYearTextField.errorText = errorMessage
            default:
                ErrorHandler.popupErrorAlert(self, errorMessage: errorMessage)
                break
            }
        }
    }
    
    // MARK: Actions
    
    /**
     Add additional user profile data. This function will navigate back to sig-in view controller once the change is made.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func addProfile(sender: AnyObject) {
        // End editing mode
        self.view.endEditing(true)
        
        // Dismiss all previous error messages
        self.resetAllError()
        
        // Show loading indicator once we start to verify invitation code from server
        self.showLoadingIndicator()
        
        // Parse filled data
        if let name = self.user.name {
            self.user.pinyin = name.toChinesePinyin() // parse chinese pin yin before save
        }
        
        // Save new user data to server asynchronously on background
        self.user.saveInBackgroundWithBlock { (success, saveError) -> Void in
            guard success else {
                if let error = ErrorHandler.parseError(saveError) {
                    self.showErrors([error])
                }
                self.dismissLoadingIndicator()
                return
            }
            
            self.dismissLoadingIndicator()
            Helper.RedirectToSignIn()
        }
    }
    
    /**
     Skip adding additional user profile, directly navigate back to sign-in view controller.
     
     - Parameters:
        - sender: The sender component who trigger the event.
     */
    @IBAction func skip(sender: AnyObject) {
        Helper.RedirectToSignIn()
    }
}

// MARK: UITextField delegate

extension AddProfileViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case self.graduationYearTextField.inputTextField:
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Validate input of each text field
        switch textField {
        case self.nameTextField.inputTextField:
            self.user.name = nameTextField.text
            
        case self.graduationYearTextField.inputTextField:
            guard let graduationYear = graduationYearTextField.text where !graduationYear.isEmpty,
                let graduationYearValue = Int(graduationYear) else { break }
            
            self.user.graduationYear = graduationYearValue
            
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

// MARK: GraduationYearPickerView delegates

extension AddProfileViewController: GraduationYearPickerDelegate {
    func confirmSelection(picker: GraduationYearPickerView, launchTextField: UITextField?) {
        guard let graduationYearTextField = launchTextField else { return }
        
        if picker.year == 0 {
            graduationYearTextField.text = nil
        }
        else {
            graduationYearTextField.text = String(picker.year)
        }
    }
}

// MARK: DataInputTextField delegates

extension AddProfileViewController: DataInputTextFieldDelegate { }
