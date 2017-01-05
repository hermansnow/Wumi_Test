//
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MessageUI
import BTNavigationDropdownMenu

class ContactTableViewController: DataLoadingTableViewController {
    
    /// Result search controller.
    private lazy var resultSearchController = UISearchController(searchResultsController: nil)
    
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    /// Array of all search contact results.
    private lazy var contacts = [User]()
    /// Array of all search contact results after applying filters.
    private lazy var filteredContacts = [User]()
    /// Tabale index path of selected contact.
    private var selectedContactIndexPath: NSIndexPath?
    
    // Private search variables
    
    /// Timer for user input. This timer will be triggered/reset when user types in search field and ended after a time period without any input.
    private var inputTimer: NSTimer?
    /// Current search string.
    private var searchString: String = ""
    /// Last search string.
    private var lastSearchString: String?
    /// Search type. Check category list in ContactSearchType.
    private var searchType: ContactSearchType = .All
    /// Flag to indicate wheter there is more result or not.
    private var hasMoreResults: Bool = false
    
    // Computed properties
    
    /// Array of contacts to be displayed on the table.
    private var displayContacts: [User] {
        get {
            if self.resultSearchController.active {
                return self.filteredContacts
            }
            else {
                return self.contacts
            }
        }
        set {
            if self.resultSearchController.active {
                self.filteredContacts = newValue
            }
            else {
                self.contacts = newValue
            }
        }
    }

    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true // Correct the layout for opaque bars
        
        // Register table cell nib
        self.tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "ContactTableViewCell")
        
        // Initialize tableview
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add resultSearchController
        self.addSearchController()
        
        // Add dropdown list
        self.addDropdownList()
        
        // Load data
        self.currentUser.loadFavoriteUsers { (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
            // Reload table data
            self.tableView.reloadData()
        }
        self.loadContacts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Modify the height of search bar's textfield
        for view in self.resultSearchController.searchBar.subviews {
            for subView in view.subviews {
                if let textField = subView as? UITextField {
                    textField.borderStyle = .None
                    textField.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let cell = sender as? ContactTableViewCell,
                indexPath = tableView.indexPathForCell(cell),
                selectedContact = self.displayContacts[safe: indexPath.row] else { return }
            
            // Stop input timer if one is running
            self.stopTimer()
            
            self.selectedContactIndexPath = indexPath
            contactVC.delegate = self
            contactVC.contact = selectedContact
            contactVC.hidesBottomBarWhenPushed = true
        }
        else if let mapVC = segue.destinationViewController as? ContactMapViewController where segue.identifier == "Show Map" {
            mapVC.displayContacts = self.displayContacts
            mapVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: UI Functions
    
    /**
     Add search controller to tabble header.
     */
    private func addSearchController() {
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.autocapitalizationType = .None;
        self.resultSearchController.searchBar.tintColor = Constants.General.Color.TitleColor
        self.resultSearchController.searchBar.barTintColor = Constants.General.Color.BackgroundColor
        self.definesPresentationContext = true
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar // Add search bar as the tableview's header
        // Initially, hide search bar under the navigation bar
        self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.tableHeaderView!.frame.size.height),
                                        animated: false)
        
        // Set delegates
        self.resultSearchController.delegate = self
        self.resultSearchController.searchBar.delegate = self
    }
    
    /**
     Add a dropdown list includes filter categories to navigation title view. 
     [Credential and reference](https://github.com/PhamBaTho/BTNavigationDropdownMenu).
     */
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All", "Favorites", "Graduation Year"]
        let optionSearchTypes: [ContactSearchType] = [.All, .Favorites, .Graduation]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = menuView
        
        // Set action closure
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = optionSearchTypes[safe: indexPath] else { return }
            
            self.searchType = searchType
            self.loadContacts() // Reload displaying contacts
        }
    }
    
    // MARK: TableView delegate & data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayContacts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 68
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as? ContactTableViewCell else {
            return UITableViewCell()
        }
        guard let contact = self.displayContacts[safe: indexPath.row] else { return cell }
        
        cell.reset()
        cell.delegate = self
        
        // Load name
        cell.nameLabel.text = contact.nameDescription
            
        // Load avatar image
        contact.loadAvatarThumbnail() { (avatarImage, imageError) -> Void in
            guard imageError == nil else {
                ErrorHandler.log(imageError.debugDescription)
                return
            }
            cell.avatarImageView.image = avatarImage
        }
        
        // Load location
        cell.locationLabel.text = contact.location.shortDiscription
            
        // Load favorite status with login user
        print(contact.name)
        print(self.currentUser.favoriteUsersArray.contains( { $0 == contact } ))
        cell.favoriteButton.selected = self.currentUser.favoriteUsersArray.contains( { $0 == contact } )
        
        // Setup initial status for additional buttons
        if !contact.emailPublic || contact.email.isEmpty {
            cell.emailButton.enabled = false
        }
        if !contact.phonePublic || contact.phoneNumber == nil || contact.phoneNumber!.isEmpty {
            cell.phoneButton.enabled = false
        }
        if contact == self.currentUser {
            cell.favoriteButton.enabled = false
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Show Contact", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    // MARK: ScrollView delegete
    
    // Load more users when dragging to bottom
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Do not trigger load more if we are still fetching results or there is no more results based on last search
        guard self.hasMoreResults else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // If we reach last 10.0 pixels from bottom, load more contacts
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMoreUsers()
        }
    }
    
    // MARK: Data handler
    
    /**
     Load contacts based on current filters.
     */
    func loadContacts() {
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Load users
        User.loadUsers(searchString: self.searchString,
                       limit: Constants.Query.LoadUserLimit,
                       type: self.searchType,
                       forUser: self.currentUser)
        { (results, error) -> Void in
            // Dismiss loading indicator
            self.dismissLoadingIndicator()
            
            guard error == nil else { return }
        
            self.displayContacts = results
            self.hasMoreResults = results.count == Constants.Query.LoadUserLimit
            self.lastSearchString = self.searchString
            self.tableView.reloadData()
                            
            // End refreshing
            self.refreshControl?.endRefreshing()
        }
    }
    
    /**
     Load more contacts based on current filters from last displayed contact.
     */
    func loadMoreUsers() {
        // Show loading indicator
        self.showLoadingIndicator()
        
        // Load more users
        User.loadUsers(searchString: self.searchString,
                       limit: Constants.Query.LoadUserLimit,
                       type: self.searchType,
                       forUser: self.currentUser,
                       sinceUser: self.displayContacts.last)
        { (results, error) -> Void in
            // Dismiss loading indicator
            self.dismissLoadingIndicator()
            
            guard error == nil && results.count > 0 else { return }
                                
            self.displayContacts.appendContentsOf(results)
            self.hasMoreResults = results.count == Constants.Query.LoadUserLimit
            self.lastSearchString = self.searchString
            self.tableView.reloadData()
        }
    }
}


// MARK: Search delegates

extension ContactTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // When end editing, try search results if there is a change in the non-empty search string
        self.triggerSearch(searchBar.text, useTimer: false)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Try search results if there is a pause when typing
        self.triggerSearch(searchController.searchBar.text, useTimer: true)
    }
    
    /**
     Trigger a new search.
     
     - Parameters:
        - searchBarText: Current search text string.
        - userTimer: Whether we will trigger a search via timer or instantly.
     */
    private func triggerSearch(searchBarText: String?, useTimer: Bool) {
        // Stop current running timer from run loop on main queue
        self.stopTimer()
        
        if let searchInput = searchBarText {
            // Quit if there is no change in the search string
            if searchInput == self.lastSearchString && !searchInput.isEmpty { return }
            else {
                self.searchString = searchInput
            }
        }
        
        // Start a new search if we have a search string
        if !self.searchString.isEmpty {
            if useTimer {
                self.startTimer() // restart the timer if we are using timer
            }
            else {
                self.loadContacts() // search instantly if we are not using timer
            }
        }
        else {
            // Otherwise, clean filtered results
            self.filteredContacts.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
    /**
     Stop current running search timer.
     */
    private func stopTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // Stop input timer if one is running
            guard let timer = self.inputTimer else { return }
            
            timer.invalidate()
        }
    }
    
    /**
     Start a new search timer.
     */
    private func startTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // start a new timer
            self.inputTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Query.searchTimeInterval,
                                                                     target: self,
                                                                     selector: #selector(self.loadContacts),
                                                                     userInfo: nil,
                                                                     repeats: false)
        }
    }
}

// MARK: Favorite button delegate

extension ContactTableViewController: FavoriteButtonDelegate {
    /**
     Add a record as favorite by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func addFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            contact = self.displayContacts[safe: indexPath.row] else { return }
        
        self.currentUser.addFavoriteUser(contact) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = true
        }
    }
    
    /**
     Remove a favorited record by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func removeFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            contact = self.displayContacts[safe: indexPath.row] else { return }
        
        self.currentUser.removeFavoriteUser(contact) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = false
            
            // Remove cell if we are on the Favorite Search Type whcih should only show favorite users
            if self.searchType == .Favorites {
                self.displayContacts.removeObject(contact)
                self.tableView.deleteRowsAtIndexPaths([indexPath],
                                                      withRowAnimation: .Automatic)
            }
        }
    }
    
    /**
     Function to be triggered when a selected status of this button is changed.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
        - selected: New selected value for this button.
     */
    func didChangeSelected(favoriteButton: FavoriteButton, selected: Bool) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell where cell.additionalButton.selected {
            favoriteButton.alpha = 1.0
        }
        else {
            favoriteButton.alpha = selected ? 1.0: 0.0
        }
    }
}

// MARK: Email button delegate

extension ContactTableViewController: EmailButtonDelegate {
    /**
     Try send an email by clicking this email button.
     
     - Parameters:
        - emailButton: Email Button clicked.
     */
    func sendEmail(emailButton: EmailButton) {
        let buttonPosition = emailButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            user = self.displayContacts[safe: indexPath.row], email = user.email else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([email])
            presentViewController(mailComposeVC,
                                  animated: true,
                                  completion: nil)
        }
        else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Mail services are not available")
        }
    }
}

// MARK: Phone button delegate

extension ContactTableViewController: PhoneButtonDelegate {
    /**
     Try call a number by clicking this phone button.
     
     - Parameters:
        - phoneButton: Email Button clicked.
     */
    func callPhone(phoneButton: PhoneButton) {
        let buttonPosition = phoneButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            user = self.displayContacts[safe: indexPath.row], phoneNumber = user.phoneNumber else { return }
        
        // Pop up a confirmation box for calling
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

// MARK: Private message button delegate

extension ContactTableViewController: PrivateMessageButtonDelegate {
    /**
     Try send an private message by clicking this button.
     
     - Parameters:
        - privateMessageButton: PrivateMessage Button clicked.
     */
    func sendMessage(privateMessageButton: PrivateMessageButton) {
        let buttonPosition = privateMessageButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            user = self.displayContacts[safe: indexPath.row] else { return }
        
        CDChatManager.sharedManager().fetchConversationWithOtherId(user.objectId) { (conv: AVIMConversation!, error: NSError!) -> Void in
            guard error == nil else {
                ErrorHandler.log("\(error)")
                return
            }
            
            // Navigate the chat room
            let chatRoomVC = ChatRoomViewController(conversation: conv)
            chatRoomVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
}

// MARK: More action button delegate

extension ContactTableViewController: MoreButtonDelegate {
    /**
     Click more button to show more.
     
     - Parameters:
        - moreButton: The MoreButton object clicked.
     */
    func showMoreActions(moreButton: MoreButton) {
        let buttonPosition = moreButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell else { return }
        
        cell.showAdditionalActions(showAdditonalActions: !moreButton.selected, withAnimation: true)
    }
}

// MARK: MFMailComposeViewController delegates

extension ContactTableViewController: MFMailComposeViewControllerDelegate {
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
    
// MARK: ContactViewController delegate

extension ContactTableViewController: ContactViewControllerDelegate {
    func finishViewContact(contactVC: ContactViewController) {
        guard let indexPath = self.selectedContactIndexPath,
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell else { return }
        
        cell.favoriteButton.selected = contactVC.isFavorite
    }
}
