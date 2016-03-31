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
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: ContactViewControllerDelegate?
    
    var selectedUserId: String?
    var selectedUser: User?
    var currentUser = User.currentUser()
    private var cells: [ContactCellRowType] = [.Professions, .Email, .Phone]
    
    var isFavorite: Bool = false {
        didSet {
            guard let favoriteButton = self.favoriteButton else { return }
            favoriteButton.selected = self.isFavorite
        }
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ContactLabelCell", bundle: nil), forCellReuseIdentifier: "ContactLabelCell")
        self.tableView.registerNib(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        
        // Enable navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem?.enabled = true
        
        // Initialize the tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Add delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.favoriteButton.delegate = self
        
        // Initialize the mask view
        self.maskView.backgroundColor = Constants.General.Color.MaskColor
        
        // Set initial status for the favorite button
        self.favoriteButton.selected = self.isFavorite
        
        // Show data
        self.displayUserData()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let delegate = self.delegate where parent == nil {
            delegate.finishViewContact(self)
        }
    }
    
    // MARK: Actions
    
    // Action when clicking email button
    func sendEmail(sender: AnyObject) {
        guard let user = self.selectedUser else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([user.email])
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Mail services are not available", block: nil)
        }
        
    }
    
    // Action when clicking message button
    func sendSMS(sender: AnyObject) {
        guard let user = self.selectedUser, phoneNumber = user.phoneNumber else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([phoneNumber])
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Message services are not available", block: nil)
        }
    }
    
    // Action when clicking phone call button
    func phoneCall(sender: AnyObject) {
        guard let user = self.selectedUser, phoneNumber = user.phoneNumber else { return }
        
        if let url = NSURL(string: "tel://\(phoneNumber)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: Help functions
    
    private func displayUserData() {
        guard let selectedUserId = self.selectedUserId else { return }
        
        // Fetch user data
        User.fetchUser(objectId: selectedUserId) { (result, error) -> Void in
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
            
            // Reload specific rows
            self.reloadRowForTypes([.Email, .Phone])
            
            // Fetch favorite relatonship with current user again as a double check
            self.currentUser.findFavoriteUser(user, block: { (count, error) -> Void in
                guard error == nil else { return }
                
                self.isFavorite = count > 0
            })
            
            // Reload profession row
            self.reloadRowForTypes([.Professions])
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileListCell") as! ProfileListCell
            cell.reset()
            cell.setCollectionViewDataSourceDelegate(self, ForIndexPath: indexPath)
            cell.titleLabel.text = ContactCellRowType.Professions.rawValue.title
            cell.addButton.hidden = true
            return cell
        
        // Email Cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactLabelCell") as! ContactLabelCell
            cell.reset()
            cell.titleLabel.text = ContactCellRowType.Email.rawValue.title
            guard let user = self.selectedUser where user.emailPublic else { return cell }
            cell.detail = user.email
                
            // Add email button
            let emailButton = cell.actionButtons[1]
            emailButton.setTitle("Sent", forState: .Normal)
            emailButton.addTarget(self, action: "sendEmail:", forControlEvents: .TouchUpInside)
            
            return cell
        
        // Phone  Cell
        case .Phone:
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactLabelCell") as! ContactLabelCell
            cell.reset()
            cell.titleLabel.text = ContactCellRowType.Phone.rawValue.title
            guard let user = self.selectedUser where user.phonePublic else { return cell }
            cell.detail = user.phoneNumber
                
            // Add SMS button
            let smsButton = cell.actionButtons[0]
            smsButton.setTitle("Message", forState: .Normal)
            smsButton.addTarget(self, action: "sendSMS:", forControlEvents: .TouchUpInside)
                
            // Add phone button
            let phoneButton = cell.actionButtons[1]
            phoneButton.setTitle("Call", forState: .Normal)
            phoneButton.addTarget(self, action: "callPhone:", forControlEvents: .TouchUpInside)
            
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
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
                Helper.PopupErrorAlert(self, errorMessage: (error?.localizedDescription)!, block: nil)
            }
            else {
                Helper.PopupErrorAlert(self, errorMessage: "Send failed", block: nil)
            }
        default:
            break
        }
        
        // Dimiss the main compose view controller
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Favorite button delegates

extension ContactViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        self.isFavorite = true
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        self.isFavorite = false
    }
}

// MARK: Custome delegate

protocol ContactViewControllerDelegate {
    func finishViewContact(contactViewController: ContactViewController)
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
