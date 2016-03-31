//
//  PostTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import SWRevealViewController

class PostTableViewController: UITableViewController {

    @IBOutlet weak var hamburgerMenuButton: UIBarButtonItem!
    var currentUser = User.currentUser()
    
    lazy var posts = [Post]()
    var updatedAtDateFormatter = NSDateFormatter()
    var searchType: Post.PostSearchType = .All
    var hasMoreResults: Bool = false
    
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
        
        // Add action for hamburgerMenuButton
        if let revealViewController = self.revealViewController() {
            revealViewController.rearViewRevealOverdraw = 0
            revealViewController.rearViewRevealWidth = UIScreen.mainScreen().bounds.width
            self.hamburgerMenuButton.target = revealViewController
            self.hamburgerMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }

    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("loadPosts"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All Activity", "News"]
        let optionSearchTypes: [Post.PostSearchType] = [.All, .Category]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = menuView
        
        // Set action closure
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = optionSearchTypes[safe: indexPath] else { return }
            
            self.searchType = searchType
            self.loadPosts()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postVC = segue.destinationViewController as? PostViewController where segue.identifier == "Show Post" {
            guard let cell = sender as? MessageTableViewCell, indexPath = tableView.indexPathForCell(cell), selectedPost = self.posts[safe: indexPath.row] else { return }
            postVC.post = selectedPost
        }
        
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let view = sender as? UserBannerView, selectedUserId = view.userObjectId else { return }
            contactVC.delegate = self
            contactVC.selectedUserId = selectedUserId
            contactVC.isFavorite = false
        }
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        guard let post = self.posts[safe: indexPath.row] else { return cell }

        cell.titleLabel.text = post.title
        cell.contentLabel.text = post.content
        cell.timeStampLabel.text = "Last updated at: " + self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
        cell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        
        post.author?.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            
            cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showUserContact:"))
            
            cell.authorView.detailLabel.text = user.name
            cell.authorView.userObjectId = user.objectId
            
            user.loadAvatar { (imageResult, imageError) -> Void in
                guard let image = imageResult where imageError == nil else { return }
                cell.authorView.avatarImageView.image = image
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Show Post", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    // MARK: ScrollView delegete
    
    // Load more users when dragging to bottom
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.refreshControl != nil && !self.refreshControl!.refreshing && self.hasMoreResults else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMorePosts()
        }
    }
    
    // MARK: Action
    func showUserContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    // MARK: Help function
    func loadPosts() {
        switch self.searchType {
        case .All:
            Post.loadPosts(limit: Constants.Query.LoadPostLimit) { (results, error) -> Void in
                self.refreshControl?.endRefreshing()
                
                guard let posts = results as? [Post] where posts.count > 0 else { return }
                
                self.posts = posts
                self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
                
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    func loadMorePosts() {
        guard let lastPost = self.posts.last else { return }
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                  cutoffTime: lastPost.updatedAt) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let posts = results as? [Post] where posts.count > 0 else { return }
            
            self.posts.appendContentsOf(posts)
            self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
            
            self.tableView.reloadData()
        }
    }
}

extension PostTableViewController: ContactViewControllerDelegate {
    func finishViewContact(contactViewController: ContactViewController) {
        return
    }
}
