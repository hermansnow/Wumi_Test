//
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class ContactTableViewController: UITableViewController {
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    var currentUser = User.currentUser()
    lazy var users = [User]() // array of users records
    lazy var filteredUsers = [User]() // array of filter results
    lazy var favoriteUsers = [User]() // set of favorite users
    
    var selectedUserIndexPath: NSIndexPath?
    var inputTimer: NSTimer?
    var searchString: String = ""
    var searchType: User.UserSearchType = .All
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
        set(results) {
            if self.resultSearchController.active {
                self.filteredUsers = results
            }
            else {
                self.users = results
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
        
        // Set delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add resultSearchController
        self.addSearchController()
        
        // Add dropdown list
        self.addDropdownList()
        
        // Load data
        self.currentUser.loadFavoriteUsers { (results, error) -> Void in
            guard let favoriteUsers = results as? [User] else { return }
            
            self.favoriteUsers = favoriteUsers
            // Reload table data
            self.tableView.reloadData()
        }
        self.loadUsers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let cell = sender as? ContactTableViewCell,
                indexPath = tableView.indexPathForCell(cell),
                selectedUser = displayUsers[safe: indexPath.row] else { return }
            // Stop input timer if one is running
            self.stopTimer()
            
            self.selectedUserIndexPath = indexPath
            contactVC.delegate = self
            contactVC.selectedUserId = selectedUser.objectId
            contactVC.isFavorite = cell.favoriteButton.selected
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
        self.resultSearchController.searchBar.barTintColor = Constants.General.Color.BackgroundColor
        self.definesPresentationContext = true
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar // Add search bar as the tableview's header
        self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.tableHeaderView!.frame.size.height), animated: true) // Initially, hide search bar under the navigation bar
    }
    
    
    // Credential and reference: https://github.com/PhamBaTho/BTNavigationDropdownMenu
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All", "Favorites", "Graduation Year"]
        let optionSearchTypes: [User.UserSearchType] = [.All, .Favorites, .Graduation]
        
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
        cell.reset()
    
        // Set cell with user data
        guard let user = displayUsers[safe: indexPath.row] else { return cell }
        
        cell.nameLabel.text = user.name
            
        // Load avatar image
        cell.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
        user.loadAvatar(ScaleToSize: cell.avatarImageView.frame.size) { (avatarImage, imageError) -> Void in
            guard imageError == nil && avatarImage != nil else {
                print("\(imageError)")
                return
            }
            cell.avatarImageView.image = avatarImage
        }
        
        // Load location
        cell.locationLabel.text = "\(user.location)"
            
        // Load favorite status with login user
        cell.favoriteButton.selected = self.favoriteUsers.contains(user)
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.delegate = self
        
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
                                guard let users = results as? [User] where error == nil else { return }
                                
                                self.displayUsers.appendContentsOf(users)
                                self.hasMoreResults = users.count == Constants.Query.LoadUserLimit
                                self.tableView.reloadData()
                            }
    }
}


// MARK: Search delegates

extension ContactTableViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchInput = searchController.searchBar.text {
            // Quit if there is no change in the search string
            if searchString == searchInput && !searchInput.isEmpty { return }
            searchString = searchInput
        }
        
        self.stopTimer()
            
        if !self.searchString.isEmpty {
            // Restart a new timer
            self.startTimer()
        }
        else {
            self.filteredUsers.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
    //Helper functions
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
                                                           selector: "loadUsers",
                                                           userInfo: nil,
                                                            repeats: false)
        }
    }
}

// MARK: Favorite button delegate

extension ContactTableViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let user = self.displayUsers[safe: favoriteButton.tag] else { return }
        self.currentUser.addFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.favoriteUsers.append(user)
            favoriteButton.selected = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let user = self.displayUsers[safe: favoriteButton.tag] else { return }
        self.currentUser.removeFavoriteUser(user) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.favoriteUsers.removeObject(user)
            favoriteButton.selected = false
            
            // Remove cell if we are on the Favorite Search Type whcih should only show favorite users
            if self.searchType == .Favorites {
                self.loadUsers()
            }
        }
    }
}
    
// MARK: ContactViewController delegate

extension ContactTableViewController: ContactViewControllerDelegate {
    func finishViewContact(contactViewController: ContactViewController) {
        guard let indexPath = self.selectedUserIndexPath, cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ContactTableViewCell else { return }
        
        // save favorite list
        if cell.favoriteButton.selected != contactViewController.isFavorite {
            cell.favoriteButton.tapped(cell.favoriteButton)
        }
    }
}
