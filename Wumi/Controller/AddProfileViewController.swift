//
//  AddProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class AddProfileViewController: ScrollTextFieldViewController {
    // MARK: Properties
    
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var userName: DataInputTextField!
    @IBOutlet weak var graduationYearTextField: DataInputTextField!
    @IBOutlet weak var skipButton: SystemButton!
    
    var avatarImage: UIImage?
    var user: User = User.currentUser()!
    
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
        graduationYearTextField.inputView = graduationYearPickerView
        
        // Set avatar image
        avatarImageView.image = avatarImage
        
        // Set skip button
        skipButton.recommanded = false
    }
    
    // MARK: Actions
    
    @IBAction func addProfile(sender: AnyObject) {
        dismissInputView()
        
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                Helper.RedirectToSignIn(self)
            }
        }
    }
    
    @IBAction func skip(sender: AnyObject) {
        Helper.RedirectToSignIn(self)
    }
    
    // MARK: UItextField delegate functions
    func textFieldDidEndEditing(textField: UITextField) {
        // Validate input of each text field
        switch textField {
        case userName:
            user.name = userName.text
        case graduationYearTextField:
            if let graduationYear = graduationYearTextField.text {
                if graduationYear.characters.count > 0 {
                    user.graduationYear = Int(graduationYear)!
                }
            }
        default:
            break
        }
    }
}
