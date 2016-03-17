//
//  EditProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var graduationYearPickerView: GraduationYearPickerView = GraduationYearPickerView()
    lazy var currentUser = User.currentUser()
    lazy var selectedProfessions = Set<Profession>()
    private var graduationYearTextfField: UITextField? // Save graduation year textfield, we need to track it when scrolling the picker
    private var cells: [EditProfileCellRowType] = [.Name, .GraduationYear, .Location, .Profession, .Email, .Phone]
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ProfileInputCell", bundle: nil), forCellReuseIdentifier: "ProfileInputCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        self.tableView.registerNib(UINib(nibName: "ProfileInputSwitchCell", bundle: nil), forCellReuseIdentifier: "ProfileInputSwitchCell")
        
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.enabled = true
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension // self-size table view cell
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Initialize the graduation year picker view
        self.graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
                                                                  size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        self.graduationYearPickerView.year = self.currentUser.graduationYear
        
        self.graduationYearPickerView.comfirmSelection = {
            self.currentUser.graduationYear = self.graduationYearPickerView.year
            guard let graduationYearTextfField = self.graduationYearTextfField else { return }
            graduationYearTextfField.text = GraduationYearPickerView.showGraduationString(self.graduationYearPickerView.year)
        }
        self.graduationYearPickerView.onYearSelected = { (year) -> Void in
            guard let graduationYearTextfField = self.graduationYearTextfField else { return }
            graduationYearTextfField.text = GraduationYearPickerView.showGraduationString(year)
        }
        self.graduationYearPickerView.cancelSelection = {
            guard let graduationYearTextfField = self.graduationYearTextfField else { return }
            graduationYearTextfField.text = GraduationYearPickerView.showGraduationString(self.currentUser.graduationYear)
        }
        
        // Initialize the mask view
        self.maskView.backgroundColor = Constants.General.Color.MaskColor
        
        // Add delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Fetch user data. We will refetch current user to guarantee to show latest data
        self.displayUserData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let countryListViewController = segue.destinationViewController as? LocationListTableViewController where segue.identifier == "Select Location" {
            countryListViewController.locationDelegate = self
            // Set current selected location
            if let contact = self.currentUser.contact {
                countryListViewController.selectedLocation = Location(Country: contact.country, City: contact.city)
            }
        }
        
        if let professionListViewController = segue.destinationViewController as? ProfessionListViewController where segue.identifier == "Select Profession" {
            professionListViewController.professionDelegate = self
            professionListViewController.avatarImage = self.profileImageView.image
            professionListViewController.selectedProfessions = self.selectedProfessions
        }
    }
    
    // MARK: Actions
    
    @IBAction func save(sender: AnyObject) {
        // Dismiss current first responder
        self.view.endEditing(true)
        
        // Save user changes
        self.saveUserData()
        
        // Save contact changes
        self.saveContactData()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changeProfileImage(sender: AnyObject) {
        let addImageSheet = SelectPhotoActionSheet(title: "Change Profile Image", message: "Choose a photo as your profile image.", preferredStyle: .ActionSheet)
        addImageSheet.delegate = self
        addImageSheet.launchViewController = self
        
        presentViewController(addImageSheet, animated: true, completion: nil)
    }
    
    // Action when click the add button on location cell
    func selectLocation(sender: UIButton) {
        performSegueWithIdentifier("Select Location", sender: self)
    }
    
    // Action when click the add button on profession cell
    func selectProfession(sender: UIButton) {
        performSegueWithIdentifier("Select Profession", sender: self)
    }
    
    // Action when click the switch button on email cell
    func changeEmailStatus(sender: UISwitch) {
        self.currentUser.emailPublic = sender.on
        
        self.reloadRowForTypes([.Email])
    }
    
    // Action when click the switch button on phone cell
    func changePhoneStatus(sender: UISwitch) {
        self.currentUser.phonePublic = sender.on
        
        self.reloadRowForTypes([.Phone])
    }

    // MARK: Help functions
    
    private func displayUserData() {
        // Fetch user data
        self.currentUser.fetchInBackgroundWithBlock() { (result, error) -> Void in
            guard let _ = result as? User where error == nil else {
                return
            }
            
            self.displayContactInformation()
            
            self.currentUser.loadAvatar(CGSize(width: self.profileImageView.frame.width, height: self.profileImageView.frame.height)) { (image, error) -> Void in
                guard error == nil else {
                    print("\(error)")
                    return
                }
                self.profileImageView.image = image
            }
            
            self.nameLabel.text = self.currentUser.name
            
            self.graduationYearLabel.text = "(" + GraduationYearPickerView.showGraduationString(self.currentUser.graduationYear) + ")"
            
            // Load professions
            Profession.fetchAllInBackground(self.currentUser.professions) { (results, error) -> Void in
                guard let selectedProfessions = results as? [Profession] where error == nil else { return }
                
                for selectedProfession in selectedProfessions {
                    self.selectedProfessions.insert(selectedProfession)
                }
                
                self.reloadRowForTypes([.Profession])
            }
            
            // Reload specific rows
            self.reloadRowForTypes([.Name, .GraduationYear, .Email, .Phone])
        }
    }
    
    private func displayContactInformation() {
        guard let contact = self.currentUser.contact else {
            // Create contact if it is nil
            self.currentUser.contact = Contact()
            self.currentUser.saveInBackground()
            return
        }
        
        // Fetch contact data
        contact.fetchInBackgroundWithBlock { (result, error) -> Void in
            guard error == nil, let contact = result as? Contact else {
                print("Error when fetch contact for user " + "\(self.currentUser)" + ": " + "\(error)")
                return
            }
                
            self.locationLabel.text = contact.location()
            
            self.reloadRowForTypes([.Location])
        }
    }
    
    private func saveUserData() {
        self.currentUser.updateProfessions(Array(selectedProfessions))
        
        let option = AVSaveOption()
        option.fetchWhenSave = true
        
        self.currentUser.saveInBackgroundWithOption(option) { (success, error) -> Void in
            guard success else {
                print("\(error)")
                // Fetch correct user data
                self.currentUser.fetchInBackgroundWithBlock(nil)
                return
            }
        }
    }
    
    private func saveContactData() {
        guard let contact = self.currentUser.contact else { return }
        
        contact.saveInBackgroundWithBlock({ (success, error) -> Void in
            guard success else {
                print("\(error)")
                self.currentUser.contact?.fetchInBackgroundWithBlock(nil)
                return
            }
        })
    }
    
    private func reloadRowForTypes(types: [EditProfileCellRowType]) {
        var indexPaths = [NSIndexPath]()
        for index in 0..<self.cells.count {
            guard let cell = self.cells[safe: index] else { continue }
            
            for type in types {
                if cell == type {
                    indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
                }
            }
        }
        if indexPaths.count > 0 {
            self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
    }
    
    func changePassword() {
        Helper.PopupInputBox(self, boxTitle: "Change Password", message: "Please input a new password",
            numberOfFileds: 2, textValues: [["placeHolder": "Please enter a new password"], ["placeHolder": "Please confirm the new password"]]) { (inputValues) -> Void in
                let newPassword = inputValues[0]
                let confirmPassword = inputValues[1]
                self.currentUser.password = newPassword
                self.currentUser.confirmPassword = confirmPassword
                self.currentUser.validateUser { (valid, validateError) -> Void in
                    guard valid else {
                        Helper.PopupErrorAlert(self, errorMessage: "\(validateError)")
                        // Do not save anything in password properties
                        self.currentUser.password = nil
                        self.currentUser.confirmPassword = nil
                        return
                    }
                }
        }
    }
}

// MARK: UITableView delegate & data source
    
extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let rowType = cells[safe: indexPath.row] else { return UITableViewCell() }
        
        switch (rowType) {
        // Name Cell
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputCell") as! ProfileInputCell
            cell.reset()
            cell.titleLabel.text = EditProfileCellRowType.Name.rawValue.title
            cell.inputTextField.placeholder = "Please enter your name"
            cell.inputTextField.text = self.currentUser.name
            cell.inputTextField.keyboardType = .NamePhonePad
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            return cell
        
        // Graduation Year Cell
        case .GraduationYear:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputCell") as! ProfileInputCell
            cell.reset()
            cell.titleLabel.text = EditProfileCellRowType.GraduationYear.rawValue.title
            cell.inputTextField.text = GraduationYearPickerView.showGraduationString(self.graduationYearPickerView.year)
            cell.inputTextField.placeholder = "Please select your graduation year"
            cell.inputTextField.inputView = self.graduationYearPickerView
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            self.graduationYearTextfField = cell.inputTextField
            return cell
        
        // Location Cell
        case .Location:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListCell") as! ProfileListCell
            cell.reset()
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = EditProfileCellRowType.Location.rawValue.title
            cell.addButton.addTarget(self, action: "selectLocation:", forControlEvents: .TouchUpInside)
            return cell
            
        // Profession Cell
        case .Profession:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListCell") as! ProfileListCell
            cell.reset()
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = EditProfileCellRowType.Profession.rawValue.title
            cell.addButton.addTarget(self, action: "selectProfession:", forControlEvents: .TouchUpInside)
            return cell
        
        // Email Cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchCell") as! ProfileInputSwitchCell
            cell.reset()
            cell.titleLabel.text = EditProfileCellRowType.Email.rawValue.title
            cell.inputTextField.text = self.currentUser.email
            cell.inputTextField.placeholder = "Please enter your email"
            cell.inputTextField.keyboardType = .EmailAddress
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.emailPublic
            cell.statusSwitch.addTarget(self, action: "changeEmailStatus:", forControlEvents: .ValueChanged)
            return cell
        
        // Phone Cell
        case .Phone:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchCell") as! ProfileInputSwitchCell
            cell.reset()
            cell.titleLabel.text = EditProfileCellRowType.Phone.rawValue.title
            cell.inputTextField.text = self.currentUser.phoneNumber
            cell.inputTextField.placeholder = "Please enter your phone number"
            cell.inputTextField.keyboardType = .PhonePad
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.phonePublic
            cell.statusSwitch.addTarget(self, action: "changePhoneStatus:", forControlEvents: .ValueChanged)
            return cell
        }
    }
}

// MARK: UICollectionView delegate & data source

extension EditProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rowType = self.cells[safe: collectionView.tag] else { return 0 }
        
        switch (rowType) {
        case .Location:
            if let contact = self.currentUser.contact where contact.location().characters.count > 0 {
                return 1
            }
            else {
                return 0
            }
        case .Profession:
            return self.selectedProfessions.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionCell", forIndexPath: indexPath) as? ProfileCollectionCell,
            rowType = self.cells[safe: collectionView.tag] else {
                return ProfileCollectionCell()
        }
        
        switch (rowType) {
        case .Location:
            guard let contact = self.currentUser.contact where contact.location().characters.count > 0 else {
                break
            }
            cell.cellLabel.text = contact.location()
            
        case .Profession:
            guard let profession = self.selectedProfessions[index: indexPath.row] else {
                break
            }
            cell.cellLabel.text = profession.name
            
        default:
            break
        }
        
        // Use "selected" style for all profile list values
        cell.style = .Selected
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}

// MARK: UIImagePicker delegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            guard let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            
            self.currentUser.saveAvatarFile(profileImage) { (success, imageError) -> Void in
                guard success else {
                    Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                    return
                }
                
                self.profileImageView.image = profileImage
            }
        }
    }
}

// MARK: UItextField delegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.frame.size.height - 140, right: 0)
        }
        
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
        guard let rowType = self.cells[safe: textField.tag] else { return }
        
        // Validate input of each text field
        switch (rowType) {
        case .Name:
            self.currentUser.name = textField.text
            if let name = self.currentUser.name {
                self.currentUser.pinyin = name.toChinesePinyin()
            }
        case .GraduationYear:
            if let graduationYear = textField.text where graduationYear.characters.count > 0, let year = Int(graduationYear) {
                self.currentUser.graduationYear = year
            }
            else {
                self.currentUser.graduationYear = 0
            }
        case .Email:
            self.currentUser.email = textField.text
        case .Phone:
            self.currentUser.phoneNumber = textField.text
        default:
            break
        }
    }
}
    
// MARK: LocationList delegate

extension EditProfileViewController: LocationListDelegate {
    func finishLocationSelection(location: Location?) {
        guard let selectedLocation = location, contact = self.currentUser.contact else { return }
        
        contact.country = selectedLocation.country
        contact.city = selectedLocation.city
        
        self.reloadRowForTypes([.Location])
    }
}

// MARK: ProfessionList delegate

extension EditProfileViewController: ProfessionListDelegate {
    func finishProfessionSelection(selectedProfessions: Set<Profession>) {
        self.selectedProfessions = selectedProfessions
        
        self.reloadRowForTypes([.Profession])
    }
}

// MARK: Custom row type

private enum EditProfileCellRowType: ProfileRow, RawRepresentable {
    case Name = "Display Name"
    case GraduationYear = "Year you graduated"
    case Location = "Your location"
    case Profession = "Professions"
    case Email = "Your email"
    case Phone = "Phone"
    
    static let allCases = [Name, GraduationYear, Location, Profession, Email, Phone]
    
    typealias RawValue = ProfileRow
    
    var rawValue: RawValue {
        switch self {
        case .Name:
            return "Display Name"
        case .GraduationYear:
            return "Year you graduated"
        case .Location:
            return "Your location"
        case .Profession:
            return "Professions"
        case .Email:
            return "Your email"
        case .Phone:
            return "Phone"
        }
    }
    
    init?(rawValue: EditProfileCellRowType.RawValue) {
        var foundType: EditProfileCellRowType? = nil
        
        for type in EditProfileCellRowType.allCases {
            if rawValue == type.rawValue {
                foundType = type
                break
            }
        }
        
        guard let type = foundType else {
            return nil
        }
        self = type
    }
}
