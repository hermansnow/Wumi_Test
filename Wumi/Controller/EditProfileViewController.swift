//
//  EditProfileViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Photos

class EditProfileViewController: DataLoadingViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var saveButtonItem = UIBarButtonItem()
    private lazy var graduationYearPickerView: GraduationYearPickerView = GraduationYearPickerView()
    
    lazy var currentUser = User.currentUser()
    lazy var selectedProfessions = Set<Profession>()
    private var graduationYearTextfField: UITextField? // Save graduation year textfield, we need to track it when scrolling the picker
    private var cells: [EditProfileCellRowType] = [.Name, .GraduationYear, .Location, .Profession, .Email, .Phone]
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ProfileInputTableCell", bundle: nil), forCellReuseIdentifier: "ProfileInputTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListTableCell", bundle: nil), forCellReuseIdentifier: "ProfileListTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileInputSwitchTableCell", bundle: nil), forCellReuseIdentifier: "ProfileInputSwitchTableCell")
        
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.enabled = true
        self.saveButtonItem = UIBarButtonItem(title: "Save",
                                              style: .Done,
                                              target: self,
                                              action: #selector(EditProfileViewController.save(_:)))
        self.navigationItem.rightBarButtonItem = self.saveButtonItem
        self.saveButtonItem.enabled = false
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension // self-size table view cell
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.bounces = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInputView))
        self.tableView.addGestureRecognizer(tap)
        
        // Initialize the graduation year picker view
        self.graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
                                                                  size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        self.graduationYearPickerView.year = self.currentUser.graduationYear
        
        self.graduationYearPickerView.comfirmSelection = {
            guard let graduationYearTextfField = self.graduationYearTextfField else { return }
            graduationYearTextfField.text = GraduationYearPickerView.showGraduationString(self.graduationYearPickerView.year)
        }
        self.graduationYearPickerView.cancelSelection = nil
        
        // Initialize the mask view
        self.maskView.backgroundColor = Constants.General.Color.LightMaskColor
        
        // Set font
        self.nameLabel.font = Constants.General.Font.ProfileNameFont
        self.graduationYearLabel.font = Constants.General.Font.ProfileNameFont
        self.locationLabel.font = Constants.General.Font.ProfileLocationFont
        
        
        // Set color
        self.nameLabel.textColor = Constants.General.Color.TextColor
        self.graduationYearLabel.textColor = Constants.General.Color.TextColor
        self.locationLabel.textColor = Constants.General.Color.TextColor
        
        // Add delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHiden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)

        // Fetch user data. We will refetch current user to guarantee to show latest data
        self.loadUserData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissReachabilityError()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let countryListViewController = segue.destinationViewController as? LocationListTableViewController where segue.identifier == "Select Location" {
            countryListViewController.locationDelegate = self
            // Set current selected location
            countryListViewController.selectedLocation = self.currentUser.location
        }
        
        if let professionListViewController = segue.destinationViewController as? ProfessionListViewController where segue.identifier == "Select Profession" {
            professionListViewController.professionDelegate = self
            professionListViewController.avatarImage = self.profileImageView.image
            professionListViewController.selectedProfessions = self.selectedProfessions
        }
    }
    
    // MARK: Actions
    // Scroll view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey],
            textField = UIResponder.currentFirstResponder() as? UITextField else { return }
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        if let textFieldOrigin = textField.superview?.convertPoint(textField.frame.origin, toView: self.view) {
            let overlapHeight = textFieldOrigin.y + keyboardRect.size.height - self.view.frame.size.height + textField.frame.size.height
            guard overlapHeight > 0 else { return }
            
            // Get keyboard animation duration
            var keyboardDuration: NSTimeInterval = 0.0
            keyboardDurVal.getValue(&keyboardDuration)
            // Scroll view
            UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
                let currentContentOffset = self.tableView.contentOffset
                self.tableView.setContentOffset(CGPointMake(currentContentOffset.x, currentContentOffset.y + overlapHeight), animated: false)
            })
        }
    }
    
    // Reset view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        // Scroll view
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        })
    }
    
    @IBAction func changeProfileImage(sender: AnyObject) {
        // Dismiss current first responder
        self.view.endEditing(true)
        
        let picker = SelectPhotoActionSheet()
        picker.cropImage = true
        picker.delegate = self
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func save(sender: AnyObject) {
        // Dismiss current first responder
        self.view.endEditing(true)
        
        // Save user changes
        self.showLoadingIndicator()
        self.currentUser.updateProfessions(Array(selectedProfessions))
        self.currentUser.saveInBackgroundWithFetch { (success, error) in
            self.hideLoadingIndicator()
            guard success else {
                Helper.PopupErrorAlert(self, errorMessage: "Save Error: " + error.description)
                return
            }
            self.displayUserBanner() // Repaint user banner for new data
            self.saveButtonItem.enabled = false
        }
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
        guard self.currentUser.emailPublic != sender.on else { return }
        
        self.currentUser.emailPublic = sender.on
        self.saveButtonItem.enabled = true
        
        self.reloadRowForTypes([.Email])
    }
    
    // Action when click the switch button on phone cell
    func changePhoneStatus(sender: UISwitch) {
        guard self.currentUser.phonePublic != sender.on else { return }
        
        self.currentUser.phonePublic = sender.on
        self.saveButtonItem.enabled = true
        
        self.reloadRowForTypes([.Phone])
    }

    // MARK: Help functions
    
    // Fetch user data
    private func loadUserData() {
        self.showLoadingIndicator()
        self.currentUser.fetchInBackgroundWithBlock() { (result, error) in
            guard let _ = result as? User where error == nil else {
                return
            }
            
            self.displayUserBanner()
            
            // Load professions
            Profession.fetchAllInBackground(self.currentUser.professions) { (results, error) -> Void in
                self.hideLoadingIndicator() // Hide general loading indicator once we receive the response from server
                guard let selectedProfessions = results as? [Profession] where error == nil else { return }
                
                for selectedProfession in selectedProfessions {
                    self.selectedProfessions.insert(selectedProfession)
                }
                
                self.tableView.reloadData()
            }
            
            // Load profile image asynchronously
            self.currentUser.loadAvatar() { (image, error) -> Void in
                guard error == nil else {
                    print("\(error)")
                    return
                }
                self.profileImageView.image = image
            }
        }
    }
    
    private func displayUserBanner() {
        self.locationLabel.text = "\(self.currentUser.location)"
            
        self.nameLabel.text = self.currentUser.name
            
        let graduationText = GraduationYearPickerView.showGraduationString(self.currentUser.graduationYear)
        if graduationText.characters.count > 0 {
            self.graduationYearLabel.text = "(" + graduationText + ")"
        }
        else {
            self.graduationYearLabel.text = graduationText
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputTableCell") as! ProfileInputTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = EditProfileCellRowType.Name.rawValue.title
            cell.inputTextField.placeholder = "Please enter your name"
            cell.inputTextField.text = self.currentUser.name
            cell.inputTextField.keyboardType = .NamePhonePad
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            return cell
        
        // Graduation Year Cell
        case .GraduationYear:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputTableCell") as! ProfileInputTableCell
            cell.reset()
            cell.enableBorder = true
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.enableBorder = true
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = EditProfileCellRowType.Location.rawValue.title
            cell.addButton.addTarget(self, action: #selector(selectLocation(_:)), forControlEvents: .TouchUpInside)
            return cell
            
        // Profession Cell
        case .Profession:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.enableBorder = true
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = EditProfileCellRowType.Profession.rawValue.title
            cell.addButton.addTarget(self, action: #selector(selectProfession(_:)), forControlEvents: .TouchUpInside)
            return cell
        
        // Email Cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchTableCell") as! ProfileInputSwitchTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = EditProfileCellRowType.Email.rawValue.title
            cell.inputTextField.text = self.currentUser.email
            cell.inputTextField.placeholder = "Please enter your email"
            cell.inputTextField.keyboardType = .EmailAddress
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.emailPublic
            cell.statusSwitch.addTarget(self, action: #selector(changeEmailStatus(_:)), forControlEvents: .ValueChanged)
            return cell
        
        // Phone Cell
        case .Phone:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchTableCell") as! ProfileInputSwitchTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = EditProfileCellRowType.Phone.rawValue.title
            cell.inputTextField.text = self.currentUser.phoneNumber
            cell.inputTextField.placeholder = "Please enter your phone number"
            cell.inputTextField.keyboardType = .PhonePad
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.phonePublic
            cell.statusSwitch.addTarget(self, action: #selector(changePhoneStatus(_:)), forControlEvents: .ValueChanged)
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
            if self.currentUser.location.description.characters.count > 0 {
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
            cell.cellLabel.text = "\(self.currentUser.location)"
            
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let rowType = self.cells[safe: collectionView.tag] else { return CGSizeZero }
        
        switch (rowType) {
        case .Location:
            let text = "\(self.currentUser.location)"
            return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont).width + 16, height: 24)
            
        case .Profession:
            guard let profession = self.selectedProfessions[index: indexPath.row], text = profession.name else { return CGSizeZero }
            return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont).width + 16, height: 24)
            
        default:
            return CGSizeZero
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6
    }
}

// MARK: SelectPhotoActionSheetDelegate delegate

extension EditProfileViewController: SelectPhotoActionSheetDelegate  {
    func selectPhotoActionSheet(controller: SelectPhotoActionSheet, didFinishePickingPhotos images: [UIImage], assets: [PHAsset]?, sourceType: UIImagePickerControllerSourceType) {
        guard let profileImage = images.first else { return }
        
        self.currentUser.saveAvatarFile(profileImage) { (success, imageError) -> Void in
            guard success else {
                Helper.PopupErrorAlert(self, errorMessage: "\(imageError)")
                return
            }
            
            self.profileImageView.image = profileImage
        }
    }
}

// MARK: UItextField delegate

extension EditProfileViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let rowType = self.cells[safe: textField.tag] else { return false }
        
        // Validate input of each text field
        switch (rowType) {
        case .GraduationYear:
            return false
        default:
            return true
        }
    }
    
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = Constants.General.Color.LightBackgroundColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let rowType = self.cells[safe: textField.tag] else { return }
        
        // Validate input of each text field
        switch (rowType) {
        case .Name:
            guard self.currentUser.name != textField.text else { break }
            
            self.currentUser.name = textField.text
            if let name = self.currentUser.name {
                self.currentUser.pinyin = name.toChinesePinyin()
            }
            self.saveButtonItem.enabled = true
        case .GraduationYear:
            var year: Int?
            if let graduationYear = textField.text where graduationYear.characters.count > 0 {
                year = Int(graduationYear)
            }
            else {
                year = 0
            }
            guard let selectedYear = year where self.currentUser.graduationYear != year else { break }
            
            self.currentUser.graduationYear = selectedYear
            self.saveButtonItem.enabled = true
        case .Email:
            guard self.currentUser.email != textField.text else { break }
            
            self.currentUser.email = textField.text
            self.saveButtonItem.enabled = true
        case .Phone:
            guard self.currentUser.phoneNumber != textField.text else { break }
            
            self.currentUser.phoneNumber = textField.text
            
        default:
            break
        }
        
        textField.backgroundColor = UIColor.whiteColor()
    }
}
    
// MARK: LocationList delegate

extension EditProfileViewController: LocationListDelegate {
    func finishLocationSelection(location: Location?) {
        guard let selectedLocation = location where selectedLocation != self.currentUser.location else { return }
        
        self.currentUser.location = selectedLocation
        self.saveButtonItem.enabled = true
        
        self.reloadRowForTypes([.Location])
    }
}

// MARK: ProfessionList delegate

extension EditProfileViewController: ProfessionListDelegate {
    func finishProfessionSelection(selectedProfessions: Set<Profession>) {
        guard selectedProfessions.subtract(self.selectedProfessions).count > 0 else { return }
        
        self.selectedProfessions = selectedProfessions
        self.saveButtonItem.enabled = true
        
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
