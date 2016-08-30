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

class ContactTableViewController: UITableViewController {
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    var currentUser = User.currentUser()
    lazy var users = [User]() // array of users records
    lazy var filteredUsers = [User]() // array of filter results
    
    var selectedUserIndexPath: NSIndexPath?
    var inputTimer: NSTimer?
    var searchString: String = "" // String of next search
    var lastSearchString: String? // String of last search
    var searchType: UserSearchType = .All
    var hasMoreResults: Bool = false
    
    // Computed properties
    var displayUsers: [User] {
        get {
            if self.resultSearchController.active {
                return self.filteredUsers
            }
            else {
                return self.users
            }
        }
        set {
            if self.resultSearchController.active {
                self.filteredUsers = newValue
            }
            else {
                self.users = newValue
            }
        }
    }

    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true // Correct the layout for opaque bars
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        
        // Initialize tableview
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        
        // Add resultSearchController
        self.addSearchController()
        
        // Add dropdown list
        self.addDropdownList()
        
        // Set delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.resultSearchController.delegate = self
        self.resultSearchController.searchBar.delegate = self
        
        // Load data
        self.currentUser.loadFavoriteUsers { (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
            // Reload table data
            self.tableView.reloadData()
        }
        self.loadUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Modify the height of textfield
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
                selectedUser = self.displayUsers[safe: indexPath.row] else { return }
            // Stop input timer if one is running
            self.stopTimer()
            
            self.selectedUserIndexPath = indexPath
            contactVC.delegate = self
            contactVC.selectedUserId = selectedUser.objectId
            contactVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: Helper functions
    
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
        self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.tableHeaderView!.frame.size.height), animated: false) // Initially, hide search bar under the navigation bar
    }
    
    
    // Credential and reference: https://github.com/PhamBaTho/BTNavigationDropdownMenu
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All", "Favorites", "Graduation Year"]
        let optionSearchTypes: [UserSearchType] = [.All, .Favorites, .Graduation]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = menuView
        
        // Set action closure
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = optionSearchTypes[safe: indexPath] else { return }
            
            self.searchType = searchType
            self.loadUsers()
        }
    }
    
    // MARK: TableView delegate & data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayUsers.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 68
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
        cell.reset()
    
        // Set cell with user data
        guard let user = displayUsers[safe: indexPath.row] else { return cell }
        
        cell.nameLabel.text = user.name
            
        // Load avatar image
        cell.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
        user.loadAvatarThumbnail() { (avatarImage, imageError) -> Void in
            guard imageError == nil && avatarImage != nil else {
                print("\(imageError)")
                return
            }
            cell.avatarImageView.image = avatarImage
        }
        
        // Load location
        cell.locationLabel.text = "\(user.location)"
            
        // Load favorite status with login user
        cell.delegate = self
        cell.favoriteButton.selected = self.currentUser.favoriteUsersArray.contains( { $0 == user } )
        
        //
        if !user.emailPublic || user.email.characters.count <= 0 {
            cell.emailButton.enabled = false
        }
        if !user.phonePublic || user.phoneNumber == nil || user.phoneNumber!.characters.count <= 0 {
            cell.phoneButton.enabled = false
        }
        if user == self.currentUser {
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
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMoreUsers()
        }
    }
    
    // MARK: Data handlers
    func loadUsers() {
        self.currentUser.loadUsers(limit: Constants.Query.LoadUserLimit,
                                    type: self.searchType,
                            searchString: self.searchString) { (results, error) -> Void in
                                guard let users = results as? [User] where error == nil else { return }
                
                                self.displayUsers = users
                                self.hasMoreResults = users.count == Constants.Query.LoadUserLimit
                                self.lastSearchString = self.searchString
                                
                                self.tableView.reloadData()
                            
                                // End refreshing
                                self.refreshControl?.endRefreshing()
                            }
    }
    
    // Load more users based on filters
    func loadMoreUsers() {
        self.currentUser.loadUsers(limit: Constants.Query.LoadUserLimit,
                                    type: self.searchType,
                            searchString: self.searchString,
                               sinceUser: self.displayUsers.last) { (results, error) -> Void in
                                guard let users = results as? [User] where error == nil && users.count > 0 else { return }
                                
                                self.displayUsers.appendContentsOf(users)
                                self.hasMoreResults = users.count == Constants.Query.LoadUserLimit
                                self.lastSearchString = self.searchString
                                
                                self.tableView.reloadData()
                            }
    }
}


// MARK: Search delegates

extension ContactTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // When end editing, try search results if there is a change in the non-empty search string
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.triggerSearch(searchBar.text, useTimer: false)
    }
    
    // Try search results if there is a pause when typing
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.triggerSearch(searchController.searchBar.text, useTimer: true)
    }
    
    // Trigger search
    func triggerSearch(searchBarText: String?, useTimer: Bool) {
        // Stop current running timer from run loop on main queue
        self.stopTimer()
        
        if let searchInput = searchBarText {
            // Quit if there is no change in the search string
            if searchInput == lastSearchString && !searchInput.isEmpty { return }
            else {
                searchString = searchInput
            }
        }
        
        if !self.searchString.isEmpty {
            // Start a search
            if useTimer {
                self.startTimer() // restart the timer if we are using timer
            }
            else {
                self.loadUsers() // search instantly if we are not using timer
            }
        }
        else {
            self.filteredUsers.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
    func stopTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // Stop input timer if one is running
            guard let timer = self.inputTimer else { return }
            
            timer.invalidate()
        }
    }
    
    func startTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // start a new timer
            self.inputTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Query.searchTimeInterval,
                                                             target: self,
                                                           selector: #selector(self.loadUsers),
                                                           userInfo: nil,
                                                            repeats: false)
        }
    }
}

// MARK: Favorite button delegate

extension ContactTableViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition) else { return }
        
        guard let user = self.displayUsers[safe: indexPath.row] else { return }
        
        self.currentUser.addFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition), user = self.displayUsers[safe: indexPath.row] else { return }
        
        self.currentUser.removeFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = false
            
            // Remove cell if we are on the Favorite Search Type whcih should only show favorite users
            if self.searchType == .Favorites {
                self.displayUsers.removeObject(user)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
    
    func didChangeSelected(favoriteButton: FavoriteButton, selected: Bool) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition), cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell where cell.additionalButton.selected {
            favoriteButton.alpha = 1.0
        }
        else {
            favoriteButton.alpha = selected ? 1.0: 0.0
        }
    }
}

// MARK: Email button delegate

extension ContactTableViewController: EmailButtonDelegate {
    func sendEmail(emailButton: EmailButton) {
        let buttonPosition = emailButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition), user = self.displayUsers[safe: indexPath.row], email = user.email else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([email])
            presentViewController(mailComposeVC, animated: true, completion: nil)
        }
        else {
            Helper.PopupErrorAlert(self, errorMessage: "Mail services are not available")
        }
    }
}

// MARK: Phone button delegate

extension ContactTableViewController: PhoneButtonDelegate {
    func callPhone(phoneButton: PhoneButton) {
        let buttonPosition = phoneButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            user = self.displayUsers[safe: indexPath.row], phoneNumber = user.phoneNumber else { return }
        
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

// MARK: Private message button delegate

extension ContactTableViewController: PrivateMessageButtonDelegate {
    func sendMessage(privateMessageButton: PrivateMessageButton) {
        let buttonPosition = privateMessageButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            user = self.displayUsers[safe: indexPath.row] else { return }
        
        CDChatManager.sharedManager().fetchConversationWithOtherId(user.objectId, callback: { (conv: AVIMConversation!, error: NSError!) -> Void in
            if (error != nil) {
                print("error: \(error)")
            } else {
                let chatRoomVC = ChatRoomViewController(conversation: conv)
                chatRoomVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatRoomVC, animated: true)
            }
        })

    }
}

// MARK: More action button delegate

extension ContactTableViewController: MoreButtonDelegate {
    func showMoreActions(moreButton: MoreButton) {
        let buttonPosition = moreButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell else { return }
        
        cell.showAdditionalActions(!moreButton.selected, withAnimation: true)
    }
}

// MARK: MFMailComposeViewController delegates

extension ContactTableViewController: MFMailComposeViewControllerDelegate {
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
    
// MARK: ContactViewController delegate

extension ContactTableViewController: ContactViewControllerDelegate {
    func finishViewContact(contactVC: ContactViewController) {
        guard let indexPath = self.selectedUserIndexPath,
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell else { return }
        
        cell.favoriteButton.selected = contactVC.isFavorite
    }
}
