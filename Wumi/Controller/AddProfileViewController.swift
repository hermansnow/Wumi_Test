//
//  AddProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class AddProfileViewController: ScrollTextFieldViewController, DataInputTextFieldDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: DataInputTextField!
    @IBOutlet weak var graduationYearTextField: DataInputTextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Date Picker for graduationYearTextField
        let graduationYearPicker = WMGraduationYearPicker()
        graduationYearPicker.onYearSelected = { (year: Int) in
            if year == 0 {
                self.graduationYearTextField.text = nil
            }
            else {
                self.graduationYearTextField.text = String(year)
            }
        }
        self.graduationYearTextField.inputView = graduationYearPicker
        self.graduationYearTextField.addInputToolBar()
        
        user = User.currentUser()!
        user.loadProfileImageWithBlock { (valid, error) -> Void in
            if valid {
                self.profileImageView.image = self.user.profileImage
            }
            else {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
            }
        }
    }
    
    // Frame will change after ViewWillAppear because of AutoLayout.
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set circular profile image button
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
    }
    
    // MARK:Actions
    @IBAction func addProfile(sender: AnyObject) {
        dismissInputView()
        
        self.user.editInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)", dismissButtonTitle: "Cancel")
            }
            else {
                self.navigationController?.popToRootViewControllerAnimated(true) // Finished Sign Up, back to root of the navigation view controller stack (assume to be the sign-in view)。 Sign-in view should automatically navigate to main view since this sign-up user is stored as current user
            }
        }
    }
    
    @IBAction func skip(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true) // The root view controller is designed to be the Sign In View Controller
    }
    
    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        dismissInputView()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let error: String = ""
        
        // Validate input of each text field
        switch textField {
        case self.userName:
            self.user.name = self.userName.text
        case self.graduationYearTextField:
            if let graduationYear = self.graduationYearTextField.text {
                if graduationYear.characters.count > 0 {
                    self.user.graduationYear = Int(graduationYear)!
                }
            }
        default:
            break
        }
        
        if let field = textField as? DataInputTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }

    
}
