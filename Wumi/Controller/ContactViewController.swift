//
//  ContactViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: DataLoadingViewController {

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
    
    /// ContactViewController delegete.
    var delegate: ContactViewControllerDelegate?
    /// Contact to be displayed.
    var contact: User?
    /// Flag to indicate whether this contact is favorited or not.
    var isFavorite: Bool = false {
        didSet {
            self.favoriteButton.selected = self.isFavorite
        }
    }
    
    /// Current login user.
    private var currentUser = User.currentUser()
    /// Array of contact information cells
    private var cells = [ProfileRow]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ProfileLabelTableCell",
                                         bundle: nil),
                                   forCellReuseIdentifier: "ProfileLabelTableCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListTableCell",
                                         bundle: nil),
                                   forCellReuseIdentifier: "ProfileListTableCell")
        
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.enabled = true
        
        
        // Add delegates
        self.favoriteButton.delegate = self
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .None
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: self.tableView.bounds.size.width,
                                                              height: 20))
        self.tableView.keyboardDismissMode = .OnDrag
        self.tableView.bounces = false
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(self.dismissInputView)))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Set up subview components
        self.setupImageView()
        self.setupLabels()
        self.addPrivateMessageInputField()
        
        // Add notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHiden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        // Show data
        self.loadContactData()
        
        // Hide favorite section if open my contact
        if let contact = self.contact where contact == self.currentUser {
            self.favoriteLabel.alpha = 0.0
            self.favoriteButton.alpha = 0.0
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let text = self.privateMessageTextInputField.text where !text.isEmpty {
            self.privateMessageButton.enabled = true
        }
        else {
            self.privateMessageButton.enabled = false
        }
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let delegate = self.delegate where parent == nil {
            delegate.finishViewContact(self)
        }
    }
    
    // MARK: UI Functions
    
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
        self.favoriteLabel.font = Constants.General.Font.ProfileTitleFont
        
        // Set color
        self.nameLabel.textColor = Constants.General.Color.TextColor
        self.graduationYearLabel.textColor = Constants.General.Color.TextColor
        self.locationLabel.textColor = Constants.General.Color.TextColor
        self.favoriteLabel.textColor = Constants.General.Color.ThemeColor
    }
    
    /**
     Set up private message input field.
     */
    private func addPrivateMessageInputField() {
        self.privateMessageWrapperView.backgroundColor = Constants.General.Color.BackgroundColor
        self.privateMessageTextInputField.font = Constants.General.Font.InputFont
        self.privateMessageTextInputField.placeholder = "Send Message..."
        self.privateMessageTextInputField.enablesReturnKeyAutomatically = true
        self.privateMessageButton.enabled = false
        self.privateMessageButton.delegate = self
        self.privateMessageTextInputField.delegate = self
        self.privateMessageTextInputField.addTarget(self,
                                                    action: #selector(textFieldDidChange(_:)),
                                                    forControlEvents: .EditingChanged)
    }
    
    // MARK: Actions
    
    /** 
     Resize text view when showing the keyboard.
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
     */
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        self.privateMessageWrapperView.frame = CGRect(origin: CGPoint(x: self.privateMessageWrapperView.frame.origin.x,
                                                                      y: self.view.bounds.size.height - self.privateMessageWrapperView.bounds.size.height - keyboardRect.size.height),
                                                      size: self.privateMessageWrapperView.bounds.size)
    }
    
    /**
     Resize text view when dismissing the keyboard.
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
     */
    func keyboardWillHiden(notification: NSNotification) {
        self.privateMessageWrapperView.frame = CGRect(origin: CGPoint(x: self.privateMessageWrapperView.frame.origin.x,
                                                                      y: self.view.bounds.size.height - self.privateMessageWrapperView.bounds.size.height),
                                                      size: self.privateMessageWrapperView.bounds.size)
    }
    
    // MARK: Help functions
    
    /**
     Load a specific contact data and display it on ContactViewController.
     */
    private func loadContactData() {
        guard let contact = self.contact, contactId = contact.objectId else { return }
        
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Fetch contact data
        User.loadUserInBackground(objectId: contactId) { (user, error) in
            guard let contact = user where error == nil else {
                ErrorHandler.log("\(error)")
                self.dismissLoadingIndicator() // Dismiss loading indicator
                return
            }
            
            // Load avatar image
            contact.loadAvatar { (image, error) in
                guard let avatar = image where error == nil else {
                    ErrorHandler.log("\(error)")
                    return
                }
                self.backgroundImageView.image = avatar
            }
            
            // Set demographic labels
            self.nameLabel.text = contact.name
            self.locationLabel.text = "\(contact.location)"
            let graduationText = GraduationYearPickerView.showGraduationString(contact.graduationYear)
            if !graduationText.isEmpty {
                self.graduationYearLabel.text = "(" + graduationText + ")"
            }
            else {
                self.graduationYearLabel.text = ""
            }
            
            // Set favorite button
            self.isFavorite = self.currentUser.favoriteUsersArray.contains(contact)
            
            // Set table cells
            self.cells.removeAll()
            if contact.professions.count > 0 {
                self.cells.append("Professions")
            }
            
            if contact.emailPublic && !contact.email.isEmpty {
                self.cells.append("Email")
            }
            
            if let phone = contact.phoneNumber where contact.phonePublic && !phone.isEmpty {
                self.cells.append("Phone")
            }
            
            self.contact = contact
            self.tableView.reloadData()
            
            self.dismissLoadingIndicator() // Dismiss loading indicator
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
        guard let row = cells[safe: indexPath.row], title = row.title else {
            return UITableViewCell()
        }
        
        // Generate cell based on cell type
        switch (title) {
        // Profession Cell
        case "Professions":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListTableCell") as! ProfileListTableCell
            cell.reset()
            cell.titleLabel.text = title
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = title
            cell.addButton.alpha = 0.0
            return cell
        
        // Email Cell
        case "Email":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileLabelTableCell") as! ProfileLabelTableCell
            cell.reset()
            cell.titleLabel.text = title
            guard let contact = self.contact where contact.emailPublic else { return cell }
            
            cell.detail = contact.email
                
            // Add email button
            let emailButton = EmailButton()
            emailButton.delegate = self
            cell.actionButtons.append(emailButton)
            
            cell.setNeedsDisplay()
            return cell
        
        // Phone  Cell
        case "Phone":
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileLabelTableCell") as! ProfileLabelTableCell
            cell.reset()
            cell.titleLabel.text = title
            guard let contact = self.contact where contact.phonePublic else { return cell }
            
            cell.detail = contact.phoneNumber
            
            // Add phone button
            let phoneButton = PhoneButton()
            phoneButton.delegate = self
            cell.actionButtons.append(phoneButton)
            
            cell.setNeedsDisplay()
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: UICollectionView delegates

extension ContactViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let row = self.cells[safe: collectionView.tag], title = row.title else { return 0 }
        
        // Generate collection based on cell type
        switch (title) {
        case "Professions":
            guard let contact = self.contact else { return 0 }
            return contact.professions.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionCell", forIndexPath: indexPath) as? ProfileCollectionCell,
            row = self.cells[safe: collectionView.tag], title = row.title else {
                return ProfileCollectionCell()
        }
        
        // Generate collection based on cell type
        switch (title) {
        case "Professions":
            guard let contact = self.contact, profession = contact.professions[safe: indexPath.row] else { break }
            cell.cellLabel.text = profession.name
            
        default:
            break
        }
        
        // Use "selected" style for all profile list values
        cell.style = .Selected
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let contact = self.contact, profession = contact.professions[safe: indexPath.row], text = profession.name else { return CGSizeZero }
        
        return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont).width + 16, height: 24)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
}


// MARK: Textfield delegate

extension ContactViewController: UITextFieldDelegate {
    func textFieldDidChange(textField: UITextField) -> Bool {
        // Determine private message button's status based on filled in text. The button will be enabled only if the text field is not empty
        if let text = textField.text where !text.isEmpty {
            self.privateMessageButton.enabled = true
        }
        else {
            self.privateMessageButton.enabled = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard textField == self.privateMessageTextInputField else {
            return true
        }
        
        // Send message if click return while editing private message's text field
        self.sendMessage(self.privateMessageButton)
        
        return true
    }
}

// MARK: MFMailComposeViewController delegates

extension ContactViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result) {
        case .Sent:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is sent successfully")
        case .Saved:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is saved in draft folder")
        case .Cancelled:
            Helper.PopupInformationBox(self,
                                       boxTitle: "Send Email",
                                       message: "Email is cancelled")
        case .Failed:
            if error != nil {
                ErrorHandler.popupErrorAlert(self, errorMessage: (error?.localizedDescription)!)
            }
            else {
                ErrorHandler.popupErrorAlert(self, errorMessage: "Send failed")
            }
        }
        
        // Dimiss the main compose view controller
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Favorite button delegate

extension ContactViewController: FavoriteButtonDelegate {
    /**
     Add a record as favorite by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let contact = self.contact else { return }
        self.currentUser.addFavoriteUser(contact) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isFavorite = true
        }
    }
    
    /**
     Remove a favorited record by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let contact = self.contact else { return }
        self.currentUser.removeFavoriteUser(contact) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isFavorite = false
        }
    }
}

// MARK: Email button delegate

extension ContactViewController: EmailButtonDelegate {
    /**
     Try send an email by clicking this email button.
     
     - Parameters:
        - emailButton: Email Button clicked.
     */
    func sendEmail(emailButton: EmailButton) {
        guard let contact = self.contact else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([contact.email])
            presentViewController(mailComposeVC, animated: true, completion: nil)
        }
        else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Mail services are not available")
        }
    }
}

// MARK: Phone button delegate
/**
 Try call a number by clicking this phone button.
 
 - Parameters:
    - phoneButton: Email Button clicked.
 */
extension ContactViewController: PhoneButtonDelegate {
    func callPhone(phoneButton: PhoneButton) {
        guard let contact = self.contact, phoneNumber = contact.phoneNumber else { return }
        
        Helper.PopupConfirmationBox(self,
                                    boxTitle: nil,
                                    message: "Call \(phoneNumber)?",
                                    cancelBlock: nil)
        { (action) -> Void in
            if let url = NSURL(string: "tel:\(phoneNumber)") where UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                ErrorHandler.popupErrorAlert(self, errorMessage: "Failed to call \(phoneNumber)")
            }
        }
    }
}

// MARK: PrivateMessage button delegate

extension ContactViewController: PrivateMessageButtonDelegate {
    /**
     Try send an private message by clicking this button.
     
     - Parameters:
        - privateMessageButton: PrivateMessage Button clicked.
     */
    func sendMessage(privateMessageButton: PrivateMessageButton) {
        guard let contact = self.contact, text = privateMessageTextInputField.text else { return }
        
        guard !text.isEmpty else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Cannot send empty message")
            return
        }
        
        CDChatManager.sharedManager().sendWelcomeMessageToOther(contact.objectId, text: text) {(result, error) in
            guard error == nil else {
                ErrorHandler.log("\(error)")
                return
            }
            
            CDChatManager.sharedManager().fetchConversationWithOtherId(contact.objectId) { (conv: AVIMConversation!, error: NSError!) in
                self.privateMessageTextInputField.text = ""
                self.dismissInputView()
                
                guard error == nil else {
                    ErrorHandler.log("\(error)")
                    return
                }
                
                let chatRoomVC = ChatRoomViewController(conversation: conv)
                self.navigationController?.pushViewController(chatRoomVC, animated: true)
            }
        }
    }
}

// MARK: ContactViewController delegate

protocol ContactViewControllerDelegate {
    /**
     Function will be triggered when this view controller is finished for display and navagated back to parent view controller.
     
     - Parameters:
        - contactVC: the ContactViewController finished for displaying.
     */
    func finishViewContact(contactVC: ContactViewController)
}
