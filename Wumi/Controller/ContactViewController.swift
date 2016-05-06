//
//  ContactViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privateMessageWrapperView: UIView!
    @IBOutlet weak var privateMessageTextInputField: UITextField!
    @IBOutlet weak var privateMessageButton: PrivateMessageButton!
    
    var delegate: ContactViewControllerDelegate?
    
    var selectedUserId: String?
    var selectedUser: User?
    var currentUser = User.currentUser()
    private var cells = [ContactCellRowType]()
    
    var isFavorite: Bool = false {
        didSet {
            self.favoriteButton.selected = self.isFavorite
        }
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ProfileLabelTableCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListTableCell", bundle: nil), forCellReuseIdentifier: "ProfileListTableCell")
        
        // Add delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.favoriteButton.delegate = self
        
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.enabled = true
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .None
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 20))
        self.tableView.keyboardDismissMode = .OnDrag
        self.tableView.bounces = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInputView))
        self.tableView.addGestureRecognizer(tap)
        
        // Initialize the mask view
        self.maskView.backgroundColor = Constants.General.Color.LightMaskColor
        
        // Set font
        self.nameLabel.font = Constants.General.Font.ProfileNameFont
        self.graduationYearLabel.font = Constants.General.Font.ProfileNameFont
        self.locationLabel.font = Constants.General.Font.ProfileLocationFont
        self.favoriteLabel.font = Constants.General.Font.ProfileTitleFont
        
        
        // Set color
        self.nameLabel.textColor = Constants.General.Color.InputTextColor
        self.graduationYearLabel.textColor = Constants.General.Color.InputTextColor
        self.locationLabel.textColor = Constants.General.Color.InputTextColor
        self.favoriteLabel.textColor = Constants.General.Color.ThemeColor
        
        // Hide favorite section if open my contact
        if selectedUserId == self.currentUser.objectId {
            self.favoriteLabel.alpha = 0.0
            self.favoriteButton.alpha = 0.0
        }
        
        // Add private message input textfield
        self.addPrivateMessageInputField()
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHiden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        // Show data
        self.displayUserData()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let delegate = self.delegate where parent == nil {
            delegate.finishViewContact(self)
        }
    }
    
    // Resize text view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        self.privateMessageWrapperView.frame = CGRect(origin: CGPoint(x: self.privateMessageWrapperView.frame.origin.x, y: self.view.bounds.size.height - self.privateMessageWrapperView.bounds.size.height - keyboardRect.size.height), size: self.privateMessageWrapperView.bounds.size)
    }
    
    // Resize text view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        self.privateMessageWrapperView.frame = CGRect(origin: CGPoint(x: self.privateMessageWrapperView.frame.origin.x, y: self.view.bounds.size.height - self.privateMessageWrapperView.bounds.size.height), size: self.privateMessageWrapperView.bounds.size)
    }
    
    func addPrivateMessageInputField() {
        self.privateMessageWrapperView.backgroundColor = Constants.General.Color.BackgroundColor
        self.privateMessageTextInputField.font = Constants.General.Font.InputFont
        self.privateMessageTextInputField.placeholder = "Send Message..."
        self.privateMessageButton.enabled = false
        self.privateMessageTextInputField.delegate = self
        self.privateMessageTextInputField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    // MARK: Actions
    
    // Action when clicking message button
    func sendSMS(sender: AnyObject) {
        guard let user = self.selectedUser, phoneNumber = user.phoneNumber else { return }
        
        if let url = NSURL(string: "sms:\(phoneNumber)") where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Failed to send message to \(phoneNumber)")
        }
    }
    
    // MARK: Help functions
    
    private func displayUserData() {
        guard let selectedUserId = self.selectedUserId else { return }
        
        // Fetch user data
        User.fetchUserInBackground(objectId: selectedUserId) { (result, error) -> Void in
            guard let user = result as? User where error == nil else {
                print("\(error)")
                return
            }
            
            self.selectedUser = user
            
            user.loadAvatar() { (image, error) -> Void in
                guard error == nil else {
                    print("\(error)")
                    return
                }
                self.backgroundImageView.image = image
            }
            
            self.nameLabel.text = user.name
            
            self.locationLabel.text = "\(user.location)"
            
            let graduationText = GraduationYearPickerView.showGraduationString(user.graduationYear)
            if graduationText.characters.count > 0 {
                self.graduationYearLabel.text = "(" + graduationText + ")"
            }
            else {
                self.graduationYearLabel.text = graduationText
            }
            
            self.isFavorite = self.currentUser.favoriteUsersArray.contains(user)
            
            self.cells.removeAll()
            if user.professions.count > 0 {
                self.cells.append(.Professions)
            }
            
            if user.email.characters.count > 0 && user.emailPublic {
                self.cells.append(.Email)
            }
            
            if let phone = user.phoneNumber where phone.characters.count > 0 && user.phonePublic {
                self.cells.append(.Phone)
            }
            
            self.tableView.reloadData()
        }
    }
    
    private func reloadRowForTypes(types: [ContactCellRowType]) {
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
    
// MARK: Table view data source

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let rowType = cells[safe: indexPath.row] else { return UITableViewCell() }
        
        switch (rowType) {
        // Profession Cell
        case .Professions:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = ContactCellRowType.Professions.rawValue.title
            cell.addButton.alpha = 0.0
            return cell
        
        // Email Cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileLabelTableCell") as! ProfileLabelTableCell
            cell.reset()
            cell.titleLabel.text = ContactCellRowType.Email.rawValue.title
            guard let user = self.selectedUser where user.emailPublic else { return cell }
            cell.detail = user.email
                
            // Add email button
            let emailButton = EmailButton()
            emailButton.delegate = self
            cell.actionButtons.append(emailButton)
            
            cell.setNeedsDisplay()
            return cell
        
        // Phone  Cell
        case .Phone:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileLabelTableCell") as! ProfileLabelTableCell
            cell.reset()
            cell.titleLabel.text = ContactCellRowType.Phone.rawValue.title
            guard let user = self.selectedUser where user.phonePublic else { return cell }
            cell.detail = user.phoneNumber
            
            // Add phone button
            let phoneButton = PhoneButton()
            phoneButton.delegate = self
            cell.actionButtons.append(phoneButton)
            
            cell.setNeedsDisplay()
            return cell
        }
    }
}

// MARK: UICollectionView delegates

extension ContactViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rowType = self.cells[safe: collectionView.tag] else { return 0 }
        
        switch (rowType) {
        case .Professions:
            guard let user = self.selectedUser else { return 0 }
            return user.professions.count
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
        case .Professions:
            guard let user = self.selectedUser, profession = user.professions[safe: indexPath.row] else { break }
            cell.cellLabel.text = profession.name
            
        default:
            break
        }
        
        // Use "selected" style for all profile list values
        cell.style = .Selected
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let user = self.selectedUser, profession = user.professions[safe: indexPath.row], text = profession.name else { return CGSizeZero }
        
        return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont!).width + 16, height: 24)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
}

// MARK: MFMailComposeViewController delegates

extension ContactViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result) {
        case MFMailComposeResultSent:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is sent successfully")
        case MFMailComposeResultSaved:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is saved in draft folder")
        case MFMailComposeResultCancelled:
            Helper.PopupInformationBox(self, boxTitle: "Send Email", message: "Email is cancelled")
        case MFMailComposeResultFailed:
            if error != nil {
                Helper.PopupErrorAlert(self, errorMessage: (error?.localizedDescription)!)
            }
            else {
                Helper.PopupErrorAlert(self, errorMessage: "Send failed")
            }
        default:
            break
        }
        
        // Dimiss the main compose view controller
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Favorite button delegate

extension ContactViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let user = self.selectedUser else { return }
        self.currentUser.addFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isFavorite = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let user = self.selectedUser else { return }
        self.currentUser.removeFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isFavorite = false
        }
    }
}

// MARK: Email button delegate

extension ContactViewController: EmailButtonDelegate {
    func sendEmail(emailButton: EmailButton) {
        guard let user = self.selectedUser else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([user.email])
            presentViewController(mailComposeVC, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Mail services are not available")
        }
    }
}

// MARK: Phone button delegate

extension ContactViewController: PhoneButtonDelegate {
    func callPhone(phoneButton: PhoneButton) {
        guard let user = self.selectedUser, phoneNumber = user.phoneNumber else { return }
        
        Helper.PopupConfirmationBox(self, boxTitle: nil, message: "Call \(phoneNumber)?", cancelBlock: nil) { (action) -> Void in
            if let url = NSURL(string: "tel:\(phoneNumber)") where UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                Helper.PopupErrorAlert(self, errorMessage: "Failed to call \(phoneNumber)")
            }
        }
    }
}

// MARK: Textfield delegate

extension ContactViewController: UITextFieldDelegate {
    func textFieldDidChange(textField: UITextField) -> Bool {
        self.privateMessageButton.enabled = textField.text?.characters.count > 0
        return true
    }
}

// MARK: Custome delegate

protocol ContactViewControllerDelegate {
    func finishViewContact(contactVC: ContactViewController)
}

// MARK: Custom row type

private enum ContactCellRowType: ProfileRow, RawRepresentable {
    case Professions = "Professions"
    case Email = "Email"
    case Phone = "Phone"
    
    static let allCases = [Professions, Email, Phone]
    
    typealias RawValue = ProfileRow
    
    var rawValue: RawValue {
        switch self {
        case .Professions:
            return "Professions"
        case .Email:
            return "Email"
        case .Phone:
            return "Phone"
        }
    }
    
    init?(rawValue: ContactCellRowType.RawValue) {
        var foundType: ContactCellRowType? = nil
        
        for type in ContactCellRowType.allCases {
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
