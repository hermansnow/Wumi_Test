//
//  WMAddProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMAddProfileViewController: WMRegisterViewController {

    @IBOutlet weak var userName: WMDataInputTextField!
    @IBOutlet weak var graduationYearTextField: WMDataInputTextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left image icon for each text field
        self.setLeftIconForTextField(self.userName)
        self.setLeftIconForTextField(self.graduationYearTextField)
        
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
        self.graduationYearTextField.inputAccessoryView = inputToolBar(self.graduationYearTextField)
        
    }
    
    // MARK:Actions    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        dismissInputView()
    }
    
    @IBAction func addProfile(sender: AnyObject) {
        dismissInputView()
        
        self.user.addProfileInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                let alert = UIAlertController(title: "Failed", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.navigationController?.popToRootViewControllerAnimated(true) // Finished Sign Up, back to root of the navigation view controller stack (assume to be the sign-in view)
            }
        }
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
        
        if let field = textField as? WMDataInputTextField {
            field.setRightErrorViewForTextFieldWithErrorMessage(error)
        }
    }
    
    // Left view of text field is used to place specific icon
    func setLeftIconForTextField(textField: WMDataInputTextField) {
        var imageName = ""
        
        switch textField {
        case self.userName:
            imageName = "Name"
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
