//
//  WMEditProfileTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class WMEditProfileTableViewController: UITableViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    var accountSettings = [Setting]()
    var personalSettings = [Setting]()
    var sections = [[Setting]]()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Get log in user
        user = User.currentUser()!
        
        setupSections()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    // MARK: tableview delegates
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        if let setting = settingForIndexPath(indexPath) {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                eventHandlerForSetting(setting, withCell: cell)
            }
        }
    }
    
    // MARK: Actions
    func eventHandlerForSetting(setting: Setting, withCell cell: UITableViewCell) {
        switch setting.identifier {
        case "Graduation Year":
            cell.accessoryView!.becomeFirstResponder()
        case "Log Out":
            let alert = UIAlertController(title: "Log Out?", message: "Logout will not delete any data. You can still log in with this account. ", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { (UIAlertAction) -> Void in
                PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                    if error != nil {
                        // TODO alert
                    }
                    else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("Log In View Controller")
                        self.presentViewController(loginViewController, animated: true, completion: nil)
                    }
                })
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func doneToolButtonClicked(sender: UIBarButtonItem){
        self.view.endEditing(true)
        
    }
    
    // MARK: Helper functions
    func setupSections() {
        setupAccountSettings()
        setupPersonalSettings()
        self.sections.append(self.accountSettings)
        self.sections.append(self.personalSettings)
    }
    
    func setupAccountSettings() {
        self.accountSettings.append(Setting(identifier: "Account", type: .PlainText))
        self.userNameLabel.text = user.username
        self.accountSettings.append(Setting(identifier: "Password", type: .Disclosure))
        self.accountSettings.append(Setting(identifier: "Email", type: .Disclosure))
    }
    
    func setupPersonalSettings() {
        self.personalSettings.append(Setting(identifier: "Name", type: .Disclosure, name: "Name", value: user.name))
        // Setup year picker
        let graduationYearTextField = WMDataInputTextField()
        let graduationYearPicker = WMGraduationYearPicker()
        graduationYearPicker.onYearSelected = { (year: Int) in
            if year == 0 {
                graduationYearTextField.text = nil
            }
            else {
                graduationYearTextField.text = String(year)
            }
        }
        graduationYearPicker.setSelectRowForYear(user.graduationYear)
        graduationYearTextField.inputView = graduationYearPicker
        graduationYearTextField.inputAccessoryView = inputToolBar(graduationYearTextField)
        //let setting = Setting(identifier: "Graduation Year", title: "Graduation Year", type: .PickerCell, detail: "\(user.graduationYear)")
        //setting.accessaryView = graduationYearTextField
        //self.personalSettings.append(setting)
    }
    
    func settingForIndexPath(indexPath: NSIndexPath) -> Setting? {
        if indexPath.section >= self.sections.count {
            return nil
        }
        
        if indexPath.row >= self.sections[indexPath.section].count {
            return nil
        }
        
        return self.sections[indexPath.section][indexPath.row]
    }
    
    // MARK:View components functions
    func inputToolBar(textField: UITextField) -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolbar.barStyle = .Default;
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneToolButtonClicked:")
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }
    
    
}
