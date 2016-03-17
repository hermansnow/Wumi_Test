    //
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
    
    @IBOutlet weak var hamburgerMenuButton: UIBarButtonItem!
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    var currentUser = User.currentUser()
    lazy var users = [User]() // array of users records
    lazy var filteredUsers = [User]() // array of filter results
    lazy var favoriteUsers = [User]() // array of favorite users
    
    var inputTimer: NSTimer?
    var searchString: String = ""
    
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
    
    // Closure for fetch display data
    var fetchDisplayData = { (inout users: [User], AllowAppend append: Bool, LoadData results: [AnyObject!], WithError error: NSError!) -> Void in
        if error != nil {
            print("\(error)")
            return
        }
        
        if append {
            users.appendContentsOf(results as! [User])
        }
        else {
            users = results as! [User]
        }
    
        var contacts = [Contact]()
        for user in users {
            if let contact = user.contact {
                contacts.append(contact)
            }
            Contact.fetchAllIfNeeded(contacts)
        }
    }

    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.extendedLayoutIncludesOpaqueBars = true
        
        // Initialize resultSearchController
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.autocapitalizationType = .None;
        self.resultSearchController.searchBar.barTintColor = Constants.General.Color.BackgroundColor
        
        // Initialize tableview
        self.tableView.tableHeaderView = self.resultSearchController.searchBar // Add search bar as the tableview's header
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.tableHeaderView!.frame.size.height), animated: true)
        
        // Set delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add UIRefreshControl
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("reloadUsers"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        // Add action for hamburgerMenuButton
        if let revealViewController = self.revealViewController() {
            revealViewController.rearViewRevealOverdraw = 0
            self.hamburgerMenuButton.target = revealViewController
            self.hamburgerMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }
        
        // Load data
        self.reloadUsers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? ContactTableViewCell,
            indexPath = tableView.indexPathForCell(cell),
            contactViewController = segue.destinationViewController as? ContactViewController,
            selectedUser = displayUsers[safe: indexPath.row] {
                contactViewController.selectedUser = selectedUser
        }
    }
    
    // MARK: - TableView delegate & data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact Cell", forIndexPath: indexPath) as! ContactTableViewCell
        
        // Set cell display style
        cell.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).CGColor
        
        // Set cell with user data
        if let user = displayUsers[safe: indexPath.row] {
            cell.nameLabel.text = user.name
            
            // Reset avatar image
            cell.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
            
            // Load avatar image
            user.loadAvatar(cell.avatarImageView.frame.size) { (avatarImage, imageError) -> Void in
                guard imageError == nil && avatarImage != nil else {
                    print("\(imageError)")
                    return
                }
                cell.avatarImageView.image = avatarImage
            }
            
            // Load contact data
            if let contact = user.contact {
                cell.locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
            }
            
            // Load favorite status with login user
            if (self.favoriteUsers.indexOf(user) != nil) {
                cell.favoriteButton.selected = true
            }
            else {
                cell.favoriteButton.selected = false
            }
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.delegate = self
        }
        
        return cell
    }
    
    // MARK: ScrollView delegete
    
    // Load more users when dragging to bottom
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.refreshControl != nil && !self.refreshControl!.refreshing else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMoreUsers()
        }
    }
    
    // MARK: Data handlers
    
    // Reload users
    func reloadUsers() {
        // Load user lists
        User.loadUsers(skip: 0, limit: Constants.Query.LoadUserLimit, WithName: self.searchString) { (results, error) -> Void in
            self.fetchDisplayData(&self.displayUsers, AllowAppend: false, LoadData: results, WithError: error)
            
            if self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
            // Load favorite users for current user
            self.currentUser.favoriteUsers!.query().findObjectsInBackgroundWithBlock { (results, error) -> Void in
                guard let favoriteUsers = results as? [User] else { return }
                self.favoriteUsers = favoriteUsers
                
                // Reload table data
                self.tableView.reloadData()
            }
        }
    }
    
    func loadMoreUsers() {
        User.loadUsers(skip: self.displayUsers.count, limit: Constants.Query.LoadUserLimit, WithName: self.searchString) { (results, error) -> Void in
            self.fetchDisplayData(&self.displayUsers, AllowAppend: true, LoadData: results, WithError: error)
            
            self.tableView.reloadData()
        }
    }
}

// MARK: Favorite button delegate

extension ContactTableViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        self.currentUser.addFavoriteUser(self.displayUsers[safe: favoriteButton.tag]) { (result, error) -> Void in
            guard error != nil else { return }
            favoriteButton.selected = result
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        self.currentUser.removeFavoriteUser(self.displayUsers[safe: favoriteButton.tag]) { (result, error) -> Void in
            guard error != nil else { return }
            favoriteButton.selected = result
        }
    }
}
    
// MARK: Search delegates

extension ContactTableViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchInput = searchController.searchBar.text {
            searchString = searchInput
        }
        
        // Stop input timer if one is running
        if inputTimer != nil {
            inputTimer!.invalidate()
        }
        
        if !searchString.isEmpty {
            // Restart a new timer
            inputTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Query.searchTimeInterval, target: self, selector: "reloadUsers", userInfo: nil, repeats: false)
        }
        else {
            self.filteredUsers.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
}
