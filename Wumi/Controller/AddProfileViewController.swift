//
//  AddProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class AddProfileViewController: ScrollTextFieldViewController, DataInputTextFieldDelegate {
    // MARK: Properties
    
    @IBOutlet weak var avatarBackgroundView: ColorGradientView!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var nameTextField: DataInputTextField!
    @IBOutlet weak var graduationYearTextField: DataInputTextField!
    @IBOutlet weak var skipButton: SystemButton!
    
    var avatarImage: UIImage?
    var user: User!
    private lazy var maskLayer = CAShapeLayer()
    
    // MARK: Life cycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Date Picker for graduationYearTextField
        let graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
                                                                                size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        graduationYearPickerView.onYearSelected = { (year: Int) in
            if year == 0 {
                self.graduationYearTextField.text = nil
            }
            else {
                self.graduationYearTextField.text = String(year)
            }
        }
        graduationYearTextField.inputTextField.inputView = graduationYearPickerView
        
        // Set avatar image
        avatarImageView.image = avatarImage
        
        // Set skip button
        skipButton.recommanded = false
        
        // Set background views
        avatarBackgroundView.colors = [Constants.General.Color.ThemeColor, UIColor.whiteColor()]
        maskLayer.fillColor = Constants.SignIn.Color.MaskColor.CGColor
        
        // Set textfields
        nameTextField.inputTextField.autocapitalizationType = .Words
        
        // Set delegates
        nameTextField.delegate = self
        graduationYearTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // Set iniatial first responder
        nameTextField.inputTextField.becomeFirstResponder()
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
        avatarBackgroundView.layer.insertSublayer(maskLayer, below: avatarImageView.layer)
        
        // Redraw DataInput Text Field
        nameTextField.drawUnderlineBorder()
        graduationYearTextField.drawUnderlineBorder()
    }
    
    // MARK: Actions
    
    @IBAction func addProfile(sender: AnyObject) {
        dismissInputView()
        
        user.saveInBackgroundWithBlock { (success, error) -> Void in
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
    
    // MARK: UItextField delegatess
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Validate input of each text field
        switch textField {
        case nameTextField.inputTextField:
            user.name = nameTextField.text
            if let name = user.name {
                user.pinyin = name.toChinesePinyin()
            }
        case graduationYearTextField.inputTextField:
            if let graduationYear = graduationYearTextField.text {
                if graduationYear.characters.count > 0 {
                    user.graduationYear = Int(graduationYear)!
                }
            }
        default:
            break
        }
    }
    
    // MARK: DataInputTextField delegates
    
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        dismissInputView()
    }
}
