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
    
    var avatarImage: UIImage?
    var user: User = User()
    private lazy var maskLayer = CAShapeLayer()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Date Picker for graduationYearTextField
        let graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
                                                                                size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        graduationYearPickerView.comfirmSelection = {
            if graduationYearPickerView.year == 0 {
                self.graduationYearTextField.text = nil
            }
            else {
                self.graduationYearTextField.text = String(graduationYearPickerView.year)
            }
        }
        graduationYearPickerView.cancelSelection = nil
        self.graduationYearTextField.inputTextField.inputView = graduationYearPickerView
        
        // Set avatar image
        if avatarImage != nil {
            self.avatarImageView.image = avatarImage
        }
        else {
            self.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
        }
        
        // Set background views
        self.avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        
        // Add avatar view mask
        self.maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        self.avatarBackgroundView.layer.insertSublayer(self.maskLayer, below: self.avatarImageView.layer)
        
        // Set textfields
        self.nameTextField.inputTextField.autocapitalizationType = .Words
        self.nameTextField.inputTextField.tag = 1
        self.graduationYearTextField.inputTextField.tag = 2
        
        // Set skip button
        self.skipButton.recommanded = false
        
        // Set delegates
        self.nameTextField.delegate = self
        self.graduationYearTextField.delegate = self
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
        self.maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight),
                                          cornerRadius: maskWidth / 2).CGPath
        self.maskLayer.position = CGPoint(x: (avatarBackgroundView.bounds.width - maskWidth) / 2,
                                          y: (avatarBackgroundView.bounds.height - maskHeight) / 2)
        
        // Redraw DataInput Text Field
        self.nameTextField.drawUnderlineBorder()
        self.graduationYearTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    @IBAction func addProfile(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.user.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                Helper.RedirectToSignIn()
            }
        }
    }
    
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
            if let name = user.name {
                user.pinyin = name.toChinesePinyin()
            }
            
        case self.graduationYearTextField.inputTextField:
            guard let graduationYear = graduationYearTextField.text where graduationYear.characters.count > 0,
            let graduationYearValue = Int(graduationYear) else { break }
            user.graduationYear = graduationYearValue
            
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

// MARK: DataInputTextField delegates

extension AddProfileViewController: DataInputTextFieldDelegate {
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}
