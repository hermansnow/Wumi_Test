//
//  EditProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,
                                 UINavigationControllerDelegate, UIImagePickerControllerDelegate, LocationListDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var graduationYearPickerView: GraduationYearPickerView = GraduationYearPickerView()
    lazy var user = User.currentUser()
    var cellTitles = ["Display Name", "Year you graduated", "Your location", "Your email", "Phone"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.backBarButtonItem?.enabled = true
        
        // Initialize the tableview
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = Constants.General.Color.BackgroundColor
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Register nib
        tableView.registerNib(UINib(nibName: "ProfileInputCell", bundle: nil), forCellReuseIdentifier: "ProfileInputCell")
        tableView.registerNib(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        tableView.registerNib(UINib(nibName: "ProfileInputSwitchCell", bundle: nil), forCellReuseIdentifier: "ProfileInputSwitchCell")
        
        // Add taleview delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        // Initialize the graduation year picker view
        graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
            size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        graduationYearPickerView.year = user.graduationYear
        graduationYearPickerView.comfirmSelection = {
            self.user.graduationYear = self.graduationYearPickerView.year
            self.graduationYearLabel.text = self.showGraduationLable(self.user.graduationYear)
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
        }
        graduationYearPickerView.cancelSelection = {
            self.graduationYearLabel.text = self.showGraduationLable(self.user.graduationYear)
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
        }

        // Fetch user data
        user.fetchInBackgroundWithBlock { (result, error) -> Void in
            self.displayUserData()
            
            // Create contact if it is nil
            if self.user.contact ==  nil {
                self.user.contact = Contact()
                self.user.saveInBackground()
            }
            // Otherwise, fetch data from server
            else {
                self.user.contact!.fetchInBackgroundWithBlock { (result, error) -> Void in
                    if error != nil {
                        print("Error when fetch contact for user " + "\(self.user)" + ": " + "\(error)")
                        return
                    }
                    
                    self.displayContactInformation()
                }
            }
        }
    }
    
    // MARK: Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        // Name Cell
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputCell", forIndexPath: indexPath) as! ProfileInputCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            cell.inputTextField.text = user.name
            cell.inputTextField.keyboardType = .NamePhonePad
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            return cell
        // Graduation Year Cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputCell", forIndexPath: indexPath) as! ProfileInputCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            cell.inputTextField.text = showGraduationLable(graduationYearPickerView.year)
            cell.inputTextField.inputView = graduationYearPickerView
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            return cell
        // Location Cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListCell", forIndexPath: indexPath) as! ProfileListCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            if let contact = user.contact {
                cell.removeAllListElements()
                let label = ProfileListLabel()
                label.text = contact.location()
                if label.text?.characters.count > 0 {
                    cell.addListElement(label)
                }
            }
            cell.addButton.addTarget(self, action: "addLocation:", forControlEvents: .TouchUpInside)
            cell.setNeedsDisplay()
            return cell
        // Email Cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchCell", forIndexPath: indexPath) as! ProfileInputSwitchCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            cell.inputTextField.text = user.email
            cell.inputTextField.keyboardType = .EmailAddress
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            if user.emailPublic {
                cell.statusLabel.text = "Public"
                cell.statusSwitch.on = true
            }
            else {
                cell.statusLabel.text = "Private"
                cell.statusSwitch.on = false
            }
            cell.statusSwitch.addTarget(self, action: "changeEmailStatus:", forControlEvents: .ValueChanged)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchCell", forIndexPath: indexPath) as! ProfileInputSwitchCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            cell.inputTextField.text = user.phoneNumber
            cell.inputTextField.keyboardType = .PhonePad
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            if user.phonePublic {
                cell.statusLabel.text = "Public"
                cell.statusSwitch.on = true
            }
            else {
                cell.statusLabel.text = "Private"
                cell.statusSwitch.on = false
            }
            cell.statusSwitch.addTarget(self, action: "changePhoneStatus:", forControlEvents: .ValueChanged)
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // MARK: UIImagePicker delegates and functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.user.saveAvatarFile(profileImage) { (saveImageSuccess, imageError) -> Void in
                    if saveImageSuccess {
                        self.profileImageView.image = profileImage
                    }
                    else {
                        Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    }
                }
            }
        }
    }
    
    // MARK: UItextField delegates
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.frame.size.height - 140, right: 0)
        }
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: textField.tag, inSection: 0), atScrollPosition: .Top, animated: true)
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.tableView.contentInset = UIEdgeInsetsZero
        }
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Validate input of each text field
        switch (textField.tag) {
        case 0:
            user.name = textField.text
            if let name = user.name {
                user.pinyin = name.toChinesePinyin()
            }
        case 1:
            if let graduationYear = textField.text where graduationYear.characters.count > 0 {
                user.graduationYear = Int(graduationYear)!
            }
            else {
                user.graduationYear = 0
            }
        case 3:
            user.email = textField.text
        case 4:
            user.phoneNumber = textField.text
        default:
            break
        }
    }
    
    // MARK: LocationList delegates
    
    func finishLocationSelection(location: Location?) {
        if let selectedLocation = location {
            user.contact!.country = selectedLocation.country
            user.contact!.city = selectedLocation.city
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // MARK: Actions
    
    @IBAction func save(sender: AnyObject) {
        // Dismiss current first responder
        view.endEditing(true)
        
        // Save user changes
        let option = AVSaveOption()
        option.fetchWhenSave = true
        
        user.saveInBackgroundWithOption(option) { (success, error) -> Void in
            if !success {
                print("\(error)")
                // Fetch correct user data
                self.user.fetchInBackgroundWithBlock(nil)
            }
        }
        
        // Save contact changes
        user.contact?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if !success {
                print("\(error)")
                self.user.contact?.fetchInBackgroundWithBlock(nil)
            }
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changeProfileImage(sender: AnyObject) {
        let addImageSheet = SelectPhotoActionSheet(title: "Change Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    // Action when click the add button on location cell
    func addLocation(sender: UIButton) {
        performSegueWithIdentifier("Select Location", sender: self)
    }
    
    // Action when click the switch button on email cell
    func changeEmailStatus(sender: UISwitch) {
        user.emailPublic = sender.on
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .None)
    }
    
    // Action when click the switch button on phone cell
    func changePhoneStatus(sender: UISwitch) {
        user.phonePublic = sender.on
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: .None)
    }
    
    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let countryListViewController = segue.destinationViewController as? LocationListTableViewController where segue.identifier == "Select Location" {
            countryListViewController.locationDelegate = self
            countryListViewController.selectedLocation = Location(Country: user.contact!.country, City: user.contact!.city)
        }
    }
    
    // MARK: Help functions
    
    private func displayUserData() {
        user.loadAvatar(CGSize(width: profileImageView.frame.width, height: profileImageView.frame.height)) { (image, error) -> Void in
            if error != nil {
                print("\(error)")
            }
            
            self.profileImageView.image = image
        }
        
        maskView.backgroundColor = Constants.SignIn.Color.MaskColor
        
        nameLabel.text = user.name
        
        if user.graduationYear > 0 {
            graduationYearLabel.text = "(\(user.graduationYear))"
        }
        else {
            graduationYearLabel.text = ""
        }
        
        // Reload specific rows
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0),
                                          NSIndexPath(forRow: 1, inSection: 0),
                                          NSIndexPath(forRow: 3, inSection: 0),
                                          NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: .None)
    }
    
    private func displayContactInformation() {
        locationLabel.text = ""
        
        if let contact = user.contact {
            locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
        }
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .None)
    }
    
    private func showGraduationLable(graduationYear: Int) -> String {
        if graduationYear == 0 {
            return "Please select your graduation year"
        }
        else {
            return "\(graduationYear)"
        }
    }
    
    func changePassword() {
        Helper.PopupInputBox(self, boxTitle: "Change Password", message: "Please input a new password",
            numberOfFileds: 2, textValues: [["placeHolder": "Please enter a new password"], ["placeHolder": "Please confirm the new password"]]) { (inputValues) -> Void in
                let newPassword = inputValues[0]
                let confirmPassword = inputValues[1]
                self.user.password = newPassword
                self.user.confirmPassword = confirmPassword
                self.user.validateUser { (valid, validateError) -> Void in
                    if !valid {
                        Helper.PopupErrorAlert(self, errorMessage: "\(validateError)")
                        // Do not save anything in password properties
                        self.user.password = nil
                        self.user.confirmPassword = nil
                        return
                    }
                }
        }
    }
}
