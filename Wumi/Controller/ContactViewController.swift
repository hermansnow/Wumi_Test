//
//  ContactViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, FavoriteButtonDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var loginUser = User.currentUser()
    var cellTitles = ["email", "Phone"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.backBarButtonItem?.enabled = true
        
        // Initialize the tableview
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Register nib
        tableView.registerNib(UINib(nibName: "ContactLabelCell", bundle: nil), forCellReuseIdentifier: "ContactLabelCell")
        
        // Add delegates
        tableView.dataSource = self
        tableView.delegate = self
        favoriteButton.delegate = self
        
        // Initialize the mask view
        maskView.backgroundColor = Constants.General.Color.MaskColor
        
        // Show data
        displayUserData()
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
        // Email Cell
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactLabelCell", forIndexPath: indexPath) as! ContactLabelCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            if user != nil && user!.emailPublic {
                cell.detailLabel.text = user!.email
                
                // Add email button
                let emailButton = cell.actionButtons[1]
                emailButton.setTitle("Sent", forState: .Normal)
                emailButton.addTarget(self, action: "sendEmail:", forControlEvents: .TouchUpInside)
                if cell.detailLabel.text?.characters.count > 0 {
                    emailButton.enabled = true
                }
                else {
                    emailButton.enabled = false
                }
            }
            return cell
        // Phone  Cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactLabelCell", forIndexPath: indexPath) as! ContactLabelCell
            cell.titleLabel.text = cellTitles[safe: indexPath.row]
            if user != nil && user!.phonePublic {
                cell.detailLabel.text = user?.phoneNumber
                
                // Add SMS button
                let smsButton = cell.actionButtons[0]
                smsButton.setTitle("Message", forState: .Normal)
                smsButton.addTarget(self, action: "sendSMS:", forControlEvents: .TouchUpInside)
                if cell.detailLabel.text?.characters.count > 0 {
                    smsButton.enabled = true
                }
                else {
                    smsButton.enabled = false
                }
                
                // Add phone button
                let phoneButton = cell.actionButtons[1]
                phoneButton.setTitle("Call", forState: .Normal)
                phoneButton.addTarget(self, action: "callPhone:", forControlEvents: .TouchUpInside)
                if cell.detailLabel.text?.characters.count > 0 {
                    phoneButton.enabled = true
                }
                else {
                    phoneButton.enabled = false
                }
            }
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // MARK: MFMailComposeViewController delegates
    
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
    
    // MARK: Favorite button delegates
    
    func addFavorite(favoriteButton: FavoriteButton) {
        if user != nil {
            loginUser.addFavoriteUser(user)
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        if user != nil {
            loginUser.removeFavoriteUser(user)
        }
    }
    
    // MARK: Actions
    
    func sendEmail(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([user!.email])
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Mail services are not available")
        }
        
    }
    
    func sendSMS(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([user!.phoneNumber!])
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Mail services are not available")
        }
    }
    
    func phoneCall(sender: AnyObject) {
        if let url = NSURL(string: "tel://\(user!.phoneNumber!)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func changeFavorite(sender: AnyObject) {
        
    }
    // MARK: Help functions
    
    private func displayUserData() {
        if let contactUser = user {
            // Fetch user data
            contactUser.fetchInBackgroundWithBlock { (result, error) -> Void in
                contactUser.loadAvatar(CGSize(width: self.backgroundImageView.frame.width, height: self.backgroundImageView.frame.height)) { (image, error) -> Void in
                    if error != nil {
                        print("\(error)")
                    }
                    
                    self.backgroundImageView.image = image
                }
                
                self.nameLabel.text = contactUser.name
                
                self.graduationYearLabel.text = self.showGraduationLable(contactUser.graduationYear)
                
                // Reload specific rows
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0),
                    NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                
                self.loginUser.findFavoriteUser(contactUser, block: { (count, error) -> Void in
                    self.favoriteButton.selected = count > 0
                })
                
                self.displayContactInformation()
            }
        }
    }
    
    private func displayContactInformation() {
        if let contactUser = self.user, contact = contactUser.contact {
            contact.fetchInBackgroundWithBlock { (result, error) -> Void in
                if error != nil {
                    print("Error when fetch contact for user " + "\(self.user)" + ": " + "\(error)")
                    return
                }
                
                self.locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
            }
        }
    }
    
    private func showGraduationLable(graduationYear: Int) -> String {
        if graduationYear == 0 {
            return ""
        }
        else {
            return "(\(graduationYear))"
        }
    }
}
