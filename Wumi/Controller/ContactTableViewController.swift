//
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var hamburgerMenuButton: UIBarButtonItem!
    var resultSearchController = UISearchController()
    
    var loadLimit = 5
    
    var users = [User]()
    var filteredUsers = [User]()
    var loadDisplayData = { (inout users: [User], results: [AnyObject!], error: NSError!) -> Void in
        if error != nil {
            print("\(error)")
            return
        }
        
        users.appendContentsOf(results as! [User])
    
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
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.hidesNavigationBarDuringPresentation = true;
        
        definesPresentationContext = false;
        tableView.tableHeaderView = resultSearchController.searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("reloadUsers"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        reloadUsers()
        
        // Add action for hamburgerMenuButton
        if self.revealViewController() != nil {
            hamburgerMenuButton.target = self.revealViewController()
            hamburgerMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.revealViewController().revealToggleAnimated(false)
    }
    
    func reloadUsers() {
        User.loadUsers(0, limit: loadLimit, WithBlock: { (results, error) -> Void in
            self.users.removeAll(keepCapacity: false)
            
            self.loadDisplayData(&self.users, results, error)
            
            if self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
            self.tableView.reloadData()
        })
    }
    
    func loadMoreUsers() {
        User.loadUsers(self.users.count, limit: loadLimit, WithBlock: { (results, error) -> Void in
            self.loadDisplayData(&self.users, results, error)
            
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if resultSearchController.active {
            return filteredUsers.count
        }
        else {
            return users.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact Cell", forIndexPath: indexPath) as! ContactTableViewCell
        
        let user: User
        if resultSearchController.active {
            user = filteredUsers[indexPath.row]
        }
        else {
            user = users[indexPath.row]
        }
        
        cell.nameLabel.text = user.name
        user.loadAvatar(cell.avatarImageView.frame.size, WithBlock: { (avatarImage, imageError) -> Void in
            if imageError == nil && avatarImage != nil {
                cell.avatarImageView.image = avatarImage
            }
            else {
                print("\(imageError)")
            }
        })
        if let contact = user.contact {
                cell.locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
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
    
    // MARK: Search delegates
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        User.loadUsers(0, limit: loadLimit, WithName: searchController.searchBar.text!, WithBlock: { (results, error) -> Void in
            self.filteredUsers.removeAll(keepCapacity: false)
            
            self.loadDisplayData(&self.filteredUsers, results, error)
            
            self.tableView.reloadData()
        })
    }
}
