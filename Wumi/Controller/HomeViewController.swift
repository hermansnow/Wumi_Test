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
import TSMessages
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var currentUserBanner: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentUserAvatarView: AvatarImageView!
    @IBOutlet weak var postTableView: UITableView!
    
    // Navigation bar items
    private var refreshControl = UIRefreshControl()
    private var searchButton = UIBarButtonItem()
    private var composePostButton = UIBarButtonItem()
    private var menuView: BTNavigationDropdownMenu?
    
    var resultSearchController = UISearchController()
    
    var currentUser = User.currentUser()
    
    // Post arrays
    private lazy var posts = [Post]()
    private lazy var filteredPosts = [Post]()
    
    // Search data
    private var isSearchMode: Bool = false
    private var searchString: String = "" // String of next search
    private var lastSearchString: String? // String of last search
    private var previousType: PostSearchType = .All
    private var searchType: PostSearchType = .All
    var category: PostCategory?
    
    private var inputTimer: NSTimer?
    private var hasMoreResults: Bool = false
    var needResearch: Bool = false
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
        
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = .None
        self.definesPresentationContext = false
        
        // Register nib
        self.postTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        
        // Initialize navigation bar
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(showSearchBar(_:)))
        self.composePostButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(composePost(_:)))
        self.navigationItem.rightBarButtonItems = [self.composePostButton, self.searchButton]
        
        // Initialize tab bar
        if let navigationController = self.navigationController {
            navigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: Constants.Post.Image.TabBarIcon?.imageWithRenderingMode(.AlwaysOriginal),
                                                           selectedImage: Constants.Post.Image.TabBarSelectedIcon?.imageWithRenderingMode(.AlwaysOriginal))
        }
        
        // Add Search Control
        self.addSearchController()
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Add Dropdown list
        self.addDropdownList()
        
        // Add current user banner
        self.addCurrentUserBanner()
        
        // Initialize tableview
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        self.postTableView.estimatedRowHeight = 180
        self.postTableView.rowHeight = UITableViewAutomaticDimension
        self.postTableView.tableFooterView = UIView(frame: CGRectZero)
        self.postTableView.separatorStyle = .None
        self.postTableView.contentInset = UIEdgeInsets(top: self.currentUserBanner.frame.size.height, left: 0, bottom: 0, right: 0)
        
        // Add action for hamburgerMenuButton
        if let revealViewController = self.revealViewController() {
            revealViewController.rearViewRevealOverdraw = 0
            revealViewController.rearViewRevealWidth = UIScreen.mainScreen().bounds.width
            let button = HamburgerMenuButton()
            button.delegate = revealViewController
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(HomeViewController.checkNewPosts),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(HomeViewController.homeTabClicked(_:)),
                                                         name: Constants.General.TabBarItemDidClickSelf,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.showPost(_:)),
                                                         name: Constants.General.CustomURLIdentifier,
                                                         object: nil)
        
        // Load posts
        self.currentUser.loadSavedPosts { (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
            // Reload table
            self.postTableView.reloadData()
        }
        self.loadPosts()
    }
    
    deinit {
        // Remove notification observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
        self.checkNewPosts()
        
        if needResearch {
            self.loadPosts()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Reset search type if there is no filter
        if self.searchType == .Filter && self.category == nil {
            self.searchType = self.previousType
            self.addDropdownList(updateOnly: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissInputView()
        self.dismissReachabilityError()
    }
    
    private func addCurrentUserBanner() {
        // Set up banner
        self.currentUserBanner.backgroundColor = Constants.General.Color.LightBackgroundColor
        self.nameLabel.textColor = Constants.General.Color.TextColor
        self.nameLabel.font = Constants.Post.Font.ListCurrentUserBanner
        self.locationLabel.textColor = Constants.Post.Color.ListDetailText
        self.locationLabel.font = Constants.Post.Font.ListUserBanner
        
        // load current user data
        let user = self.currentUser
        self.nameLabel.text = user.nameDescription
        self.locationLabel.text = user.location.description
        
        // Load avatar
        self.currentUser.loadAvatarThumbnail { (imageResult, imageError) -> Void in
            guard let image = imageResult where imageError == nil else { return }
            self.currentUserAvatarView.image = image
        }
        
        // Add gesture
        self.currentUserBanner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.editCurrentUserProfile(_:))))
        
        //
        self.view.addSubview(self.currentUserBanner)
        self.currentUserBanner.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor, constant: 0.0).active = true
        self.currentUserBanner.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor, constant: 0.0).active = true
        
        self.showCurrentUserBanner()
    }
    
    private func addSearchController() {
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.showsCancelButton = true
        self.resultSearchController.searchBar.autocapitalizationType = .None
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.tintColor = Constants.General.Color.TitleColor
        self.resultSearchController.searchBar.delegate = self
        self.resultSearchController.searchBar.showsCancelButton = false
        self.resultSearchController.automaticallyAdjustsScrollViewInsets = false
    }
    
    private func addRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(HomeViewController.loadPosts), forControlEvents: .ValueChanged)
        self.postTableView.addSubview(self.refreshControl)
    }
    
    private func addDropdownList(updateOnly update: Bool = false) {
        // Initial a dropdown list with options
        let optionTitles = ["All Activity", "Saved", "Custom Filter"]
        let optionSearchTypes: [PostSearchType] = [.All, .Saved, .Filter]
        
        // Initial title
        guard let index = optionSearchTypes.indexOf(self.searchType), title = optionTitles[safe: index] else { return }
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: optionTitles)
        
        if !update {
            // Add the dropdown list to the navigation bar
            self.navigationItem.titleView = self.menuView
        
            // Set action closure
            self.menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                guard let searchType = optionSearchTypes[safe: indexPath] else { return }
                
                self.previousType = self.searchType
                self.searchType = searchType
            
                switch searchType {
                case .All,
                     .Saved:
                    self.loadPosts()
                case .Filter:
                    self.performSegueWithIdentifier("Filter Post", sender: self)
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postVC = segue.destinationViewController as? PostViewController where segue.identifier == "Show Post" {
            postVC.delegate = self
            postVC.hidesBottomBarWhenPushed = true
            
            if let cell = sender as? PostTableViewCell,
                indexPath = self.postTableView.indexPathForCell(cell),
                selectedPost = self.displayPosts[safe: indexPath.row] {
                    postVC.post = selectedPost
                    self.selectedPostIndexPath = indexPath
            }
            if let notification = sender as? NSNotification,
                postId = notification.object as? String {
                    let post = Post()
                    post.objectId = postId
                    postVC.post = post
            }
            if let button = sender as? ReplyButton {
                let buttonPosition = button.convertPoint(CGPointZero, toView: self.postTableView)
                if let indexPath = self.postTableView.indexPathForRowAtPoint(buttonPosition),
                    selectedPost = self.displayPosts[safe: indexPath.row] {
                        postVC.post = selectedPost
                        self.selectedPostIndexPath = indexPath
                        postVC.launchReply = true
                }
            }
        }
        
        if let profileVC = segue.destinationViewController as? EditProfileViewController where segue.identifier == "Edit Profile" {
            guard let view = sender as? UIView where view == self.currentUserBanner else { return }
            
            profileVC.hidesBottomBarWhenPushed = true
        }
        
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let view = sender as? UserBannerView, selectedUserId = view.userObjectId else { return }
            contactVC.selectedUserId = selectedUserId
            contactVC.hidesBottomBarWhenPushed = true
        }
        
        if let newPostVC = segue.destinationViewController as? NewPostViewController where segue.identifier == "Compose Post" {
            newPostVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: Action
    
    func editCurrentUserProfile(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Edit Profile", sender: recognizer.view)
    }
    
    func showUserContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    func showSearchBar(sender: AnyObject) {
        self.isSearchMode = true
        
        self.postTableView.tableHeaderView = self.resultSearchController.searchBar // Add search bar to table header
        self.navigationItem.rightBarButtonItems?.removeObject(self.searchButton) // Hide right search navigation items
        
        // Hide current user banner
        self.showCurrentUserBanner()
        self.postTableView.contentInset = UIEdgeInsetsZero
        
        self.postTableView.setContentOffset(CGPoint.zero, animated: true) // scroll table back to top to show the search bar
    }
    
    func composePost(sender: AnyObject) {
        self.performSegueWithIdentifier("Compose Post", sender: self)
    }
    
    func homeTabClicked(sender: AnyObject) {
        self.postTableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated:true)
        self.loadPosts()
    }
    
    func showPost(sender: AnyObject) {
        if let notification = sender as? NSNotification, postId = notification.object as? String where Post.findPost(objectId: postId) {
            self.performSegueWithIdentifier("Show Post", sender: sender)
        }
    }
    
    // MARK: Help function
    
    // Determine the alpha of current user banner based on table content offset and status of search bar:
    private func showCurrentUserBanner () {
        // Hide user banner if search is active
        if self.isSearchMode {
            self.currentUserBanner.alpha = 0.0
            return
        }
        
        let bannerHeight = self.currentUserBanner.frame.size.height
        let offset = self.postTableView.contentOffset
        
        // Change the alpha of current user banner based on percentage of overlap between banner and table content
        self.currentUserBanner.alpha = -offset.y / bannerHeight
    }
    
    func checkNewPosts() {
        guard let navigationController = self.navigationController else { return }
        
        if let firstPost = self.displayPosts.first {
            Post.countNewPosts(self.searchType, cutoffTime: firstPost.updatedAt, user: self.currentUser, block: { (count, error) in
                guard count > 0 && error == nil else {
                    navigationController.tabBarItem.badgeValue = nil
                    return
                }
                
                if count <= 99 {
                    navigationController.tabBarItem.badgeValue = "\(count)"
                }
                else {
                    navigationController.tabBarItem.badgeValue = ""
                }
            })
        }
    }
    
    func loadPosts() {
        self.refreshControl.beginRefreshing()
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                       type: self.searchType,
                       searchString: self.searchString,
                       user: self.currentUser,
                       category: self.category) { (results, error) -> Void in
                        self.refreshControl.endRefreshing()
                        
                        guard let posts = results as? [Post] where error == nil else { return }
                    
                        self.displayPosts = posts
                        self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
                    
                        self.postTableView.reloadData()
                        
                        // Reset new post badge since we just loaded latest posts
                        if let navigationController = self.navigationController where self.searchString.characters.count == 0 {
                            navigationController.tabBarItem.badgeValue = nil
                        }
        }
    }
    
    func loadMorePosts() {
        guard let lastPost = self.displayPosts.last else { return }
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                       type: self.searchType,
                       cutoffTime: lastPost.updatedAt,
                       searchString: self.searchString,
                       user: self.currentUser,
                       category: self.category) { (results, error) -> Void in
                        self.refreshControl.endRefreshing()
                    
                        guard let posts = results as? [Post] where error == nil && posts.count > 0 else { return }
                    
                        self.displayPosts.appendContentsOf(posts)
                        self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
                    
                        self.postTableView.reloadData()
        }
    }
}

// MARK: Table view data source
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show empty view if there is no post for displaying
        if self.displayPosts.count == 0 {
            let emptyView = EmptyPostView(frame: CGRect(x: 0, y: 0, width: self.postTableView.frame.size.width, height: self.postTableView.frame.size.height))
            // Set message
            if self.searchString.characters.count == 0 {
                if self.resultSearchController.active {
                    emptyView.text = ""
                }
                else if self.refreshControl.refreshing {
                    emptyView.text = ""
                }
                else {
                    emptyView.text = "Wumi has no post data"
                }
            }
            else {
                emptyView.text = "Sorry, no post was found with your searching words: \"\(self.searchString)\""
            }
            self.postTableView.backgroundView = emptyView
        }
        return self.displayPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        guard let post = self.displayPosts[safe: indexPath.row] else { return cell }
        
        cell.reset()
        
        // Highlight searching string
        cell.highlightedString = self.searchString
        
        if let title = post.title where title.characters.count > 0 {
            cell.title = title
        }
        else {
            cell.title = "No Title"
        }
        
        cell.hideImageView = post.attachedThumbnails.count == 0 && post.mediaThumbnails.count == 0 && !post.hasPreviewImage
        
        // Fetch content
        if post.attributedContent == nil {
            post.loadExternalUrlContentWithBlock(requirePreviewImage: true) { (foundUrl) in
                guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell else { return }
                
                if !foundUrl {
                    cell.content = post.attributedContent
                    return
                }
                else {
                    self.postTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
        else {
            cell.content = post.attributedContent
        }
        
        // Load preview image from attachment media
        if post.attachedThumbnails.count > 0 || post.mediaThumbnails.count > 0 {
            post.loadFirstThumbnailWithBlock { (result, error) in
                guard let image = result, cell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell where error == nil else { return }
            
                cell.previewImage = image.scaleToHeight(100)
            }
        }
        else if let url = post.externalPreviewImageUrl{
            cell.imagePreview.sd_setImageWithURL(url, placeholderImage: Constants.General.Image.Logo)
        }
        
        cell.timeStamp = post.updatedAt.timeAgo()
        cell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        
        // Fetch author information
        if let author = post.author {
            author.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                guard let user = result as? User where error == nil else { return }
                
                cell.authorView.detailLabel.text = user.nameDescription + (user.location.description.characters.count > 0 ? ", " + user.location.description : "")
                cell.authorView.userObjectId = user.objectId
                
                user.loadAvatarThumbnail { (imageResult, imageError) -> Void in
                    guard let image = imageResult where imageError == nil else { return }
                    cell.authorView.avatarImageView.image = image
                }
                
                cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showUserContact(_:))))
            }
        }
        
        // Set up buttons
        cell.isSaved = self.currentUser.savedPostsArray.contains( { $0 == post} )
        cell.saveButton.delegate = self
        cell.replyButton.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Show Post", sender: tableView.cellForRowAtIndexPath(indexPath))
        
        self.postTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: ScrollView delegete
extension HomeViewController: UIScrollViewDelegate {
    // Load more users when dragging to bottom
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !self.refreshControl.refreshing && self.hasMoreResults else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMorePosts()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.showCurrentUserBanner() // Update current user banner
    }
}

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    // Action for cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isSearchMode = false
        
        self.navigationItem.rightBarButtonItems?.append(self.searchButton) // Add right search navigation items back
        self.postTableView.tableHeaderView = nil // Remove search bar from table header
        
        // Show user banner if possible
        self.showCurrentUserBanner()
        self.postTableView.contentInset = UIEdgeInsets(top: self.currentUserBanner.frame.size.height, left: 0, bottom: 0, right: 0)
        
        self.postTableView.setContentOffset(CGPoint(x: 0, y: -self.currentUserBanner.frame.size.height), animated: true)
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
            self.postTableView.reloadData()
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
                                                                     selector: #selector(HomeViewController.loadPosts),
                                                                     userInfo: nil,
                                                                     repeats: false)
        }
    }
}

extension HomeViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.postTableView)
        guard let indexPath = self.postTableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell,
            post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.savePost(post) { (result, error) in
            guard result && error == nil else { return }
            
            cell.isSaved = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.postTableView)
        guard let indexPath = self.postTableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell,
            post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.unsavePost(post) { (result, error) in
            guard result && error == nil else { return }
            
            cell.isSaved = false
            
            // Remove cell if we are on the Saved Search Type which should only show saved posts
            if self.searchType == .Saved {
                self.displayPosts.removeObject(post)
                self.postTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

extension HomeViewController: ReplyButtonDelegate {
    func reply(replyButton: ReplyButton) {
        self.performSegueWithIdentifier("Show Post", sender: replyButton)
    }
}

extension HomeViewController: PostViewControllerDelegate {
    func finishViewPost(postVC: PostViewController) {
        guard let indexPath = self.selectedPostIndexPath,
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell else { return }
        
        cell.isSaved = postVC.isSaved
    }
    
    func deletePost(postVC: PostViewController) {
        guard let indexPath = self.selectedPostIndexPath else { return }
        
        print(indexPath)
        
        self.displayPosts.removeAtIndex(indexPath.row)
        self.postTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}
