//
//  ContactTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var resultSearchController = UISearchController()
    
    var users = [User]()
    var filteredUsers = [User]()
    
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
        resultSearchController.hidesNavigationBarDuringPresentation = false;
        
        definesPresentationContext = false;
        navigationItem.titleView = resultSearchController.searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("loadUsers"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        loadUsers()
    }
    
    func loadUsers() {
        User.loadAllUser(0, WithBlock: { (results, error) -> Void in
            if error != nil {
                print("\(error)")
                return
            }
            
            self.users.removeAll(keepCapacity: false)
            self.users.appendContentsOf(results as! [User])
            
            
            if self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
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
        user.contact?.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
            if let contact = result as? Contact {
                cell.locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
            }
        })
        

        return cell
    }
    
    // MARK: Search delegates
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredUsers.removeAll(keepCapacity: false)
        
        
    }
}
