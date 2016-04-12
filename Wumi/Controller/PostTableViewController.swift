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
    var searchButton = UIBarButtonItem()
    var composePostButton = UIBarButtonItem()
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    var currentUser = User.currentUser()
    
    lazy var posts = [Post]()
    lazy var filteredPosts = [Post]()
    
    var updatedAtDateFormatter = NSDateFormatter()
    var inputTimer: NSTimer?
    var searchString: String = "" // String of next search
    var lastSearchString: String? // String of last search
    var searchType: PostSearchType = .All
    var hasMoreResults: Bool = false
    var selectedPostIndexPath: NSIndexPath?
    
    // Computed properties
    var displayPosts: [Post] {
        get {
            if self.resultSearchController.active {
                return self.filteredPosts
            }
            else {
                return self.posts
            }
        }
        set {
            if self.resultSearchController.active {
                self.filteredPosts = newValue
            }
            else {
                self.posts = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        
        // Initialize navigation bar
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(showSearchBar(_:)))
        self.composePostButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(composePost(_:)))
        self.navigationItem.rightBarButtonItems = [self.composePostButton, self.searchButton]
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.updatedAtDateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        
        // Add Search Control
        self.addSearchController()
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Add Dropdown list
        self.addDropdownList()
        
        // Add action for hamburgerMenuButton
        if let revealViewController = self.revealViewController() {
            revealViewController.rearViewRevealOverdraw = 0
            revealViewController.rearViewRevealWidth = UIScreen.mainScreen().bounds.width
            self.hamburgerMenuButton.target = revealViewController
            self.hamburgerMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }

        // Load posts
        self.currentUser.loadSavedPosts { (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
            // Reload table
            self.tableView.reloadData()
        }
        self.loadPosts()
    }
    
    private func addSearchController() {
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.showsCancelButton = true
        self.resultSearchController.searchBar.autocapitalizationType = .None;
        self.resultSearchController.searchBar.tintColor = Constants.General.Color.TitleColor
        self.resultSearchController.searchBar.delegate = self
        self.definesPresentationContext = true
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.loadPosts), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    private func addDropdownList() {
        // Initial a dropdown list with options
        let optionTitles = ["All Activity", "Saved"]
        let optionSearchTypes: [PostSearchType] = [.All, .Saved]
        
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
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postVC = segue.destinationViewController as? PostViewController where segue.identifier == "Show Post" {
            guard let cell = sender as? MessageTableViewCell, indexPath = tableView.indexPathForCell(cell), selectedPost = self.displayPosts[safe: indexPath.row] else { return }
            postVC.delegate = self
            postVC.post = selectedPost
            self.selectedPostIndexPath = indexPath
        }
        
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let view = sender as? UserBannerView, selectedUserId = view.userObjectId else { return }
            contactVC.selectedUserId = selectedUserId
            contactVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayPosts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        guard let post = self.displayPosts[safe: indexPath.row] else { return cell }
        
        cell.reset()
        if let title = post.title {
            cell.title = NSMutableAttributedString(string: title)
        }
        if let content = post.content {
            cell.content = NSMutableAttributedString(string: content)
        }
        cell.timeStamp = "Last updated at: " + self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
        cell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        cell.highlightString = self.searchString
        
        post.author?.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            
            cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostTableViewController.showUserContact(_:))))
            
            cell.authorView.detailLabel.text = user.name
            cell.authorView.userObjectId = user.objectId
            
            user.loadAvatarThumbnail { (imageResult, imageError) -> Void in
                guard let image = imageResult where imageError == nil else { return }
                cell.authorView.avatarImageView.image = image
            }
        }
        
        // Set up buttons
        cell.saveButton.selected = self.currentUser.savedPostsArray.contains( { $0 == post} )
        cell.saveButton.delegate = self

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.hidesBottomBarWhenPushed = true
        self.performSegueWithIdentifier("Show Post", sender: tableView.cellForRowAtIndexPath(indexPath))
        self.hidesBottomBarWhenPushed = false
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
    
    func showSearchBar(sender: AnyObject) {
        self.navigationItem.setRightBarButtonItems(nil, animated: true)
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.resultSearchController.searchBar.becomeFirstResponder()
    }
    
    func composePost(sender: AnyObject) {
        self.performSegueWithIdentifier("Compose Post", sender: self)
    }

    // MARK: Help function
    func loadPosts() {
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                        type: self.searchType,
                searchString: self.searchString,
                        user: self.currentUser) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
                
            guard let posts = results as? [Post] where error == nil else { return }
                
            self.displayPosts = posts
            self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
                
            self.tableView.reloadData()
        }
    }
    
    func loadMorePosts() {
        guard let lastPost = self.displayPosts.last else { return }
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                        type: self.searchType,
                  cutoffTime: lastPost.updatedAt,
                searchString: self.searchString,
                        user: self.currentUser) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let posts = results as? [Post] where error == nil && posts.count > 0 else { return }
            
            self.displayPosts.appendContentsOf(posts)
            self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
            
            self.tableView.reloadData()
        }
    }
}

extension PostTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    // Action for cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationItem.setRightBarButtonItems([self.composePostButton, self.searchButton], animated: true)
        self.tableView.tableHeaderView = nil
    }
    
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
                self.loadPosts() // search instantly if we are not using timer
            }
        }
        else {
            self.filteredPosts.removeAll(keepCapacity: false)
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
                                                           selector: #selector(PostTableViewController.loadPosts),
                                                           userInfo: nil,
                                                            repeats: false)
        }
    }
}

extension PostTableViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition), post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.savePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition), post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.unsavePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            favoriteButton.selected = false
            
            // Remove cell if we are on the Saved Search Type which should only show saved posts
            if self.searchType == .Saved {
                self.displayPosts.removeObject(post)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

extension PostTableViewController: PostViewControllerDelegate {
    func finishViewPost(postVC: PostViewController) {
        guard let indexPath = self.selectedPostIndexPath,
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as? MessageTableViewCell else { return }
        
        cell.saveButton.selected = postVC.isSaved
    }
}
