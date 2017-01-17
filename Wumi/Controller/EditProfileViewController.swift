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
    
    /// Save button on navigation bar.
    private lazy var saveButtonItem = UIBarButtonItem()
    /// Picker for graduatuin year.
    private lazy var graduationYearPickerView: GraduationYearPickerView = GraduationYearPickerView()
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    
    /// New Avater File.
    private var newAvatar: AVFile?
    /// New Thumbnail File.
    private var newThumbnail: AVFile?
    /// New name.
    private var newName: String?
    /// New graduation Year.
    private var newGraduationYear: Int?
    /// New location.
    private var newLocation: Location?
    /// New profession set.
    private var newProfessions: [Profession]?
    /// New email address.
    private var newEmail: String?
    /// New email status.
    private var newEmailPublic: Bool?
    /// New phone number.
    private var newPhone: String?
    /// New phone status.
    private var newPhonePublic: Bool?
    /// Profile cells.
    private lazy var cells: [ProfileRow] = ["Display Name", "Year You Graduated", "Your Location", "Professions", "Your Email", "Your Phone Number"]
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ProfileInputTableCell", bundle: nil),
                                   forCellReuseIdentifier: "ProfileInputTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListTableCell", bundle: nil),
                                   forCellReuseIdentifier: "ProfileListTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileInputSwitchTableCell", bundle: nil),
                                   forCellReuseIdentifier: "ProfileInputSwitchTableCell")
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension // self-size table view cell
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.bounces = false
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(self.dismissInputView)))
        
        // Set up subview components
        self.addNavigateButton()
        self.setupImageView()
        self.setupLabels()
        self.setupGraduationPicker()
        
        // Add table view delegates
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
        if let countryListViewController = segue.destinationViewController as? CountryListTableViewController
            where segue.identifier == "Select Location" {
            countryListViewController.locationDelegate = self
            // Set current selected location
            let location = self.newLocation ?? self.currentUser.location
            countryListViewController.selectedLocation = location
        }
        
        if let professionListViewController = segue.destinationViewController as? ProfessionListViewController
            where segue.identifier == "Select Profession" {
            professionListViewController.delegate = self
            professionListViewController.avatarImage = self.profileImageView.image
            // Set current selected professions
            let professions = self.newProfessions ?? self.currentUser.professions
            professionListViewController.selectedProfessions = professions
        }
    }
    
    // MARK: UI Functions
    
    /**
     Enable navigation bar with a save button.
     */
    private func addNavigateButton() {
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Add save button
        self.navigationItem.backBarButtonItem?.enabled = true
        self.saveButtonItem = UIBarButtonItem(title: "Save",
                                              style: .Done,
                                              target: self,
                                              action: #selector(self.save))
        self.navigationItem.rightBarButtonItem = self.saveButtonItem
        self.saveButtonItem.enabled = false
    }
    
    /**
     Set up image view.
     */
    private func setupImageView() {
        self.maskView.backgroundColor = Constants.General.Color.LightMaskColor
    }
    
    /**
     Set up data labels.
     */
    private func setupLabels() {
        // Set font
        self.nameLabel.font = Constants.General.Font.ProfileNameFont
        self.graduationYearLabel.font = Constants.General.Font.ProfileNameFont
        self.locationLabel.font = Constants.General.Font.ProfileLocationFont
        
        // Set color
        self.nameLabel.textColor = Constants.General.Color.TextColor
        self.graduationYearLabel.textColor = Constants.General.Color.TextColor
        self.locationLabel.textColor = Constants.General.Color.TextColor
    }
    
    /**
     Set up graduation picker view.
     */
    private func setupGraduationPicker() {
        self.graduationYearPickerView = GraduationYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height / 3 * 2),
                                                                 size: CGSize(width: view.frame.width, height: view.frame.height / 3)))
        self.graduationYearPickerView.year = self.currentUser.graduationYear
    }
    
    /**
     Display current user's banner over avatar image.
     */
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
    
    // MARK: Actions
    
    /**
     Scroll view when showing the keyboard
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
     */
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
    
    /**
     Reset view when dismissing the keyboard
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
     */
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
    
    /**
     Click Save button to save new user profile data to server asynchronously.
     */
    func save() {
        // Dismiss current first responder
        self.view.endEditing(true)
        
        // Show indicator
        self.showLoadingIndicator()
        
        // Update data
        if let newValue = self.newAvatar {
            self.currentUser.avatarImageFile = newValue
            self.currentUser.avatarThumbnail = self.newThumbnail
        }
        if let newValue = self.newName {
            self.currentUser.name = newValue
            self.currentUser.pinyin = newValue.toChinesePinyin()
        }
        if let newValue = self.newGraduationYear {
            self.currentUser.graduationYear = newValue
        }
        if let newValue = self.newLocation {
            self.currentUser.location = newValue
        }
        if let newValue = self.newEmail {
            self.currentUser.email = newValue
        }
        if let newValue =  self.newEmailPublic {
            self.currentUser.emailPublic = newValue
        }
        if let newValue = self.newPhone{
            self.currentUser.phoneNumber = newValue
        }
        if let newValue = self.newPhonePublic {
            self.currentUser.phonePublic = newValue
        }
        if let newValue = self.newProfessions {
            self.currentUser.updateProfessions(newValue)
        }
        
        // Save user changes
        self.currentUser.saveInBackgroundWithFetch { (success, wumiError) in
            // Dismiss indicator
            self.dismissLoadingIndicator()
            
            guard success else {
                if let error = wumiError, errorMessage = error.error where !errorMessage.isEmpty {
                    ErrorHandler.popupErrorAlert(self, errorMessage: "Save Error: " + errorMessage)
                }
                else {
                    ErrorHandler.popupErrorAlert(self, errorMessage: "Save Error: Unknown error.")
                }
                return
            }
            
            self.displayUserBanner() // Repaint user banner for new data
            self.saveButtonItem.enabled = false
        }
    }
    
    /**
     Click avatar image to change profile avatar.
     
     - Parameters:
        - sender: Image view clicked.
     */
    @IBAction func changeProfileImage(sender: AnyObject) {
        // Dismiss current first responder
        self.dismissInputView()
        
        // Launch photo selection action sheet.
        let picker = SelectPhotoActionSheet()
        picker.cropImage = true
        picker.delegate = self
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    /**
     Action when click the add button on location cell.
     
     - Parameters:
        - sender: UIButton clicked.
     */
    func selectLocation(sender: UIButton) {
        self.dismissInputView()
        
        self.performSegueWithIdentifier("Select Location", sender: self)
    }
    
    /**
     Action when click the add button on profession cell.
     
     - Parameters:
        - sender: UIButton clicked.
     */
    func selectProfession(sender: UIButton) {
        self.dismissInputView()
        
        self.performSegueWithIdentifier("Select Profession", sender: self)
    }
    
    /**
     Action when click the switch button on email cell.
     
     - Parameters:
        - sender: UISwitch tapped.
     */
    func changeEmailStatus(sender: UISwitch) {
        self.dismissInputView()
        
        guard self.currentUser.emailPublic != sender.on else { return }
        
        self.newEmailPublic = sender.on
        self.saveButtonItem.enabled = true
    }
    
    /**
     Action when click the switch button on phone cell.
     
     - Parameters:
        - sender: UISwitch tapped.
     */
    func changePhoneStatus(sender: UISwitch) {
        self.dismissInputView()
        
        guard self.currentUser.phonePublic != sender.on else { return }
        
        self.newPhonePublic = sender.on
        self.saveButtonItem.enabled = true
    }

    // MARK: Help functions
    
    /**
     Fetch current login user's data asynchronously.
     */
    private func loadUserData() {
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Fetch data in background
        self.currentUser.fetchUserInBackgroundWithBlock { (success, error) in
            // Dismiss loading indicator
            self.dismissLoadingIndicator()
            
            guard success && error == nil else {
                ErrorHandler.popupErrorAlert(self, errorMessage: "Unable to load user data.")
                return
            }
            
            // Show user banner
            self.displayUserBanner()
            
            // Load profile image asynchronously
            self.currentUser.loadAvatar() { (image, error) -> Void in
                guard error == nil else {
                    ErrorHandler.log(error?.error)
                    return
                }
                self.profileImageView.image = image
            }
            
            // Reload cells
            self.tableView.reloadData()
        }
    }
    
    /**
     Reload specific profile rows.
     
     - Parameters:
        - rows: Profile rows to be reloaded.
     */
    private func reloadProfileRows(rows: [ProfileRow]) {
        var indexPaths = [NSIndexPath]()
        for index in 0..<self.cells.count {
            guard let cell = self.cells[safe: index] else { continue }
            
            for row in rows {
                if cell == row {
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
        return self.cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let row = self.cells[safe: indexPath.row], title = row.title else {
            return UITableViewCell()
        }
        
        switch (title) {
        // Name Cell
        case "Display Name":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputTableCell") as! ProfileInputTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = title
            cell.inputTextField.placeholder = "Please enter your name"
            cell.inputTextField.text = self.newName ?? self.currentUser.name
            cell.inputTextField.keyboardType = .NamePhonePad
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            return cell
        
        // Graduation Year Cell
        case "Year You Graduated":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputTableCell") as! ProfileInputTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = title
            cell.inputTextField.text = GraduationYearPickerView.showGraduationString(self.newGraduationYear ?? self.graduationYearPickerView.year)
            cell.inputTextField.placeholder = "Please select your graduation year"
            cell.inputTextField.inputView = self.graduationYearPickerView
            cell.inputTextField.tag = indexPath.row
            cell.inputTextField.delegate = self
            self.graduationYearPickerView.launchTextField = cell.inputTextField
            self.graduationYearPickerView.delegate = self
            return cell
        
        // Location Cell
        case "Your Location":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.enableBorder = true
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = title
            cell.addButton.addTarget(self, action: #selector(self.selectLocation(_:)), forControlEvents: .TouchUpInside)
            return cell
            
        // Profession Cell
        case "Professions":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.enableBorder = true
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = title
            cell.addButton.addTarget(self, action: #selector(self.selectProfession(_:)), forControlEvents: .TouchUpInside)
            return cell
        
        // Email Cell
        case "Your Email":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchTableCell") as! ProfileInputSwitchTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = title
            cell.inputTextField.text = self.newEmail ?? self.currentUser.email
            cell.inputTextField.placeholder = "Please enter your email"
            cell.inputTextField.keyboardType = .EmailAddress
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.emailPublic
            cell.statusSwitch.addTarget(self, action: #selector(changeEmailStatus(_:)), forControlEvents: .ValueChanged)
            return cell
        
        // Phone Cell
        case "Your Phone Number":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileInputSwitchTableCell") as! ProfileInputSwitchTableCell
            cell.reset()
            cell.enableBorder = true
            cell.titleLabel.text = title
            cell.inputTextField.text = self.newPhone ?? self.currentUser.phoneNumber
            cell.inputTextField.placeholder = "Please enter your phone number"
            cell.inputTextField.keyboardType = .PhonePad
            cell.inputTextField.delegate = self
            cell.inputTextField.tag = indexPath.row
            cell.showPublic = self.currentUser.phonePublic
            cell.statusSwitch.addTarget(self, action: #selector(changePhoneStatus(_:)), forControlEvents: .ValueChanged)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: UICollectionView delegate & data source

extension EditProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let row = self.cells[safe: collectionView.tag], title = row.title else {
            return 0
        }
        
        switch (title) {
        case "Your Location":
            let location = self.newLocation ?? self.currentUser.location
            if location.description.characters.count > 0 {
                return 1
            }
            else {
                return 0
            }
        case "Professions":
            let professions = self.newProfessions ?? self.currentUser.professions
            return professions.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionCell", forIndexPath: indexPath) as? ProfileCollectionCell,
            row = self.cells[safe: collectionView.tag], title = row.title else {
                return ProfileCollectionCell()
        }
        
        switch (title) {
        case "Your Location":
            let location = self.newLocation ?? self.currentUser.location
            cell.cellLabel.text = "\(location)"
            
        case "Professions":
            let professions = self.newProfessions ?? self.currentUser.professions
            guard let profession = professions[safe: indexPath.row] else {
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
        guard let row = self.cells[safe: collectionView.tag], title = row.title else {
            return CGSizeZero
        }
        
        switch (title) {
        case "Your Location":
            let location = self.newLocation ?? self.currentUser.location
            let text = "\(location)"
            return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont).width + 16,
                          height: 24)
            
        case "Professions":
            let professions = self.newProfessions ?? self.currentUser.professions
            guard let profession = professions[safe: indexPath.row], text = profession.name else {
                return CGSizeZero
            }
            
            return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont).width + 16,
                          height: 24)
            
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
        
        User.saveAvatarFiles(profileImage) { (avatarFile, thumbnailFile, error) in
            guard error == nil else {
                ErrorHandler.popupErrorAlert(self, errorMessage: error?.error)
                return
            }
            
            self.newAvatar = avatarFile
            self.newThumbnail = thumbnailFile
            self.profileImageView.image = profileImage
            self.saveButtonItem.enabled = true
        }
    }
}

// MARK: UItextField delegate

extension EditProfileViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let row = self.cells[safe: textField.tag], title = row.title else { return false }
        
        // Validate input of each text field
        switch (title) {
        case "Year You Graduated":
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
        textField.backgroundColor = Constants.General.Color.LightBackgroundColor // Highlight current editing textfield
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let rowType = self.cells[safe: textField.tag] else { return }
        
        // Validate input of each text field
        switch (rowType) {
        case "Display Name":
            guard self.currentUser.name != textField.text else {
                self.newName = nil
                break
            }
            
            self.newName = textField.text
            self.saveButtonItem.enabled = true
        case "Your Email":
            guard self.currentUser.email != textField.text else {
                self.newEmail = nil
                break
            }
            
            self.newEmail = textField.text
            self.saveButtonItem.enabled = true
        case "Your Phone Number":
            guard self.currentUser.phoneNumber != textField.text else {
                self.newPhone = nil
                break
            }
            
            self.newPhone = textField.text
            self.saveButtonItem.enabled = true
        default:
            break
        }
        
        textField.backgroundColor = UIColor.whiteColor() // Reset textfield background color
    }
}
    
// MARK: LocationList delegate

extension EditProfileViewController: LocationListDelegate {
    func finishLocationSelection(location: Location?) {
        let curLocation = self.newLocation ?? self.currentUser.location
        
        guard let selectedLocation = location else { return }
        
        // Check whether this new selected location is diff with current user's location
        if selectedLocation != self.currentUser.location {
            self.newLocation = selectedLocation
            self.saveButtonItem.enabled = true
        }
        else {
            self.newLocation = nil
            return
        }

        
        // Check whether location changed
        if curLocation != selectedLocation {
            self.reloadProfileRows(["Your Location"])
        }
    }
}

// MARK: ProfessionList delegate

extension EditProfileViewController: ProfessionListDelegate {
    func finishProfessionSelection(selectedProfessions: [Profession]) {
        let curProfessions = self.newProfessions ?? self.currentUser.professions
        
        // Check whether this new selected professions are diff with current user's profession list
        if !selectedProfessions.compare(self.currentUser.professions) {
            self.newProfessions = selectedProfessions
            self.saveButtonItem.enabled = true
        }
        else {
            self.newProfessions = nil
        }
        
        // Check whether profession changed
        if !selectedProfessions.compare(curProfessions) {
            self.reloadProfileRows(["Professions"])
        }
    }
}

// MARK: GraduationYearPickerView delegates

extension EditProfileViewController: GraduationYearPickerDelegate {
    func confirmSelection(picker: GraduationYearPickerView, launchTextField: UITextField?) {
        guard let graduationYearTextField = launchTextField else { return }
        
        graduationYearTextField.text = GraduationYearPickerView.showGraduationString(self.graduationYearPickerView.year)
        
        if self.currentUser.graduationYear != picker.year {
            self.newGraduationYear = picker.year
            self.saveButtonItem.enabled = true
        }
        else {
            self.newGraduationYear = nil
        }
        
        graduationYearTextField.resignFirstResponder()
    }
    
    func cancelSelection(picker: GraduationYearPickerView, launchTextField: UITextField?) {
        guard let graduationYearTextField = launchTextField else { return }
        
        graduationYearTextField.resignFirstResponder()
    }
}
