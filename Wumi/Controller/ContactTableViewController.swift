    //
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController, ContactTableViewCellDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var hamburgerMenuButton: UIBarButtonItem!
    var resultSearchController: UISearchController!
    
    var loadLimit = 100 // number of records load in each query
    var searchTimeInterval = 0.3 // seconds to start search. UISearchController will only search results if end-users stop inputting with this time interval
    
    var user = User.currentUser()
    var users = [User]() // array of users records
    var filteredUsers = [User]() // array of filter results
    var favoriteUsers = [User]() // array of favorite users
    var currentUsers: [User] {
        get {
            if resultSearchController.active {
                return filteredUsers
            }
            else {
                return users
            }
        }
        set(results) {
            if resultSearchController.active {
                filteredUsers = results
            }
            else {
                users = results
            }
        }
    }
    
    var inputTimer: NSTimer?
    var searchString: String = ""
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialize resultSearchController
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.hidesNavigationBarDuringPresentation = true;
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.autocapitalizationType = .None;
        resultSearchController.searchBar.barTintColor = Constants.UI.BackgroundColor
        
        // Initialize tableview
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        tableView.setContentOffset(CGPoint(x: 0.0, y: tableView.tableHeaderView!.frame.size.height), animated: true)
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        // Add UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("reloadUsers"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Add action for hamburgerMenuButton
        if let revealViewController = self.revealViewController() {
            hamburgerMenuButton.target = revealViewController
            hamburgerMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }
        
        // Load favorite users for current user
        self.user.favoriteUsers?.query().findObjectsInBackgroundWithBlock { (results, error) -> Void in
            self.favoriteUsers = results as! [User]
            
            // Load data
            self.reloadUsers()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.revealViewController().revealToggleAnimated(false)
    }
    
    
    // Reload users
    func reloadUsers() {
        // Load user lists
        User.loadUsers(0, limit: loadLimit, WithName: searchString) { (results, error) -> Void in
            self.fetchDisplayData(&self.currentUsers, AllowAppend: false, LoadData: results, WithError: error)
            
            if self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
            self.tableView.reloadData()
        }
    }
    
    func loadMoreUsers() {
        User.loadUsers(self.users.count, limit: loadLimit) { (results, error) -> Void in
            self.fetchDisplayData(&self.currentUsers, AllowAppend: true, LoadData: results, WithError: error)
            
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact Cell", forIndexPath: indexPath) as! ContactTableViewCell
        
        if let user = currentUsers[safe: indexPath.row] {
            cell.nameLabel.text = user.name
            user.loadAvatar(cell.avatarImageView.frame.size) { (avatarImage, imageError) -> Void in
                if imageError == nil && avatarImage != nil {
                    cell.avatarImageView.image = avatarImage
                }
                else {
                    print("\(imageError)")
                }
            }
            if let contact = user.contact {
                cell.locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
            }
            
            // Set border color
            cell.contentView.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).CGColor
            
            if (favoriteUsers.indexOf(user) != nil) {
                cell.favoriteButton.selected = true
            }
            else {
                cell.favoriteButton.selected = false
            }
            
            // Set delegate
            cell.delegate = self
        }
        
        return cell
    }
    
    // Load more contacts when dragging to bottom
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if self.refreshControl!.refreshing {
            return
        }
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            loadMoreUsers()
        }
    }
    
    // MARK: - Contact table view cell delegates
    func addFavorite(cell: ContactTableViewCell) {
        // get related user
        if let indexPath = tableView.indexPathForCell(cell) {
            if indexPath.section != 0 { return }
            
            user.addFavoriteUser(currentUsers[safe: indexPath.row])
        }
    }
    
    func removeFavorite(cell: ContactTableViewCell) {
        // get related user
        if let indexPath = tableView.indexPathForCell(cell) {
            if indexPath.section != 0 { return }
            
            user.removeFavoriteUser(currentUsers[safe: indexPath.row])
        }
    }
    
    // MARK: Search delegates
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
            inputTimer = NSTimer.scheduledTimerWithTimeInterval(searchTimeInterval, target: self, selector: "reloadUsers", userInfo: nil, repeats: false)
        }
        else {
            
            self.filteredUsers.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
}
