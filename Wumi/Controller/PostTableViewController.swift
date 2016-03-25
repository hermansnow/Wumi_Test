//
//  PostTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class PostTableViewController: UITableViewController {

    var currentUser = User.currentUser()
    
    lazy var posts = [Post]()
    var updatedAtDateFormatter = NSDateFormatter()
    var searchType: Post.PostSearchType = .All
    var cutoffTime: NSDate? // cutoffTime of the latest pull request, we will only query new posts created larger than this cutoff time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.updatedAtDateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Add Dropdown list
        self.addDropdownList()
        
        // Load posts
        self.loadPosts()
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("loadPosts"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All Activity"]
        let optionSearchTypes: [Post.PostSearchType] = [.All]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = menuView
        
        // Set action closure
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = optionSearchTypes[safe: indexPath] else { return }
            
            self.searchType = searchType
            self.cutoffTime = nil
            self.loadPosts()
        }
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        guard let post = self.posts[safe: indexPath.row] else { return cell }

        cell.titleLabel.text = post.title
        cell.contentLabel.text = post.content
        cell.timeStampLabel.text = "Last updated at: " + self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
        
        post.author?.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            
            cell.authorView.detailLabel.text = user.name
            
            user.loadAvatar { (imageResult, imageError) -> Void in
                guard let image = imageResult where imageError == nil else { return }
                cell.authorView.avatarImageView.image = image
            }
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
            self.loadPosts()
        }
    }
    
    // MARK: Help function
    func loadPosts() {
        let cutoffTime = self.cutoffTime
        self.cutoffTime = NSDate()
        self.currentUser.loadPosts(cutoffTime) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let posts = results as? [Post] where posts.count > 0 else { return }
            
            self.posts.insertContentsOf(posts, at: 0)
            
            self.tableView.reloadData()
        }
    }

}
