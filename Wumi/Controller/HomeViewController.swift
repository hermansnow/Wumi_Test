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
import TTTAttributedLabel

class HomeViewController: DataLoadingViewController {
    
    @IBOutlet weak var currentUserBanner: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentUserAvatarView: AvatarImageView!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var newPostNotificationView: UIView!
    @IBOutlet weak var newPostLabel: UILabel!
    
    /// Search controller.
    private lazy var searchController = UISearchController(searchResultsController: nil)
    /// Post table refresh controller.
    private lazy var refreshControl = UIRefreshControl()
    /// Navigation bar item for searching post.
    private lazy var searchButton = UIBarButtonItem()
    /// Navigation bar item for composing new post.
    private lazy var composePostButton = UIBarButtonItem()
    /// Dropdown menu for short-cut search types.
    private var menuView: BTNavigationDropdownMenu?
    
    // Constaints
    
    /// Auto-layout constraint for new post notification view's top anchor.
    private var newPostNotificationTopConstraint: NSLayoutConstraint?
    /// Auto-layout constrain for new post notification view's bottom anchor.
    private var newPostNotificationBottomConstraint: NSLayoutConstraint?
    
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    /// Array of all posts found by category.
    private lazy var categoryPosts = [Post]()
    /// Array of posts found in searching controller.
    private lazy var searchResultPosts = [Post]()
    
    // Search variables
    
    /// Whether the post table is showing search bar or not.
    private var isShowingSearchBar: Bool = false
    /// Whether is loading posts or not.
    private var isLoadingPost: Bool {
        return self.isLoading || self.refreshControl.refreshing
    }
    /// Whether show default table or not.
    private var showDefaultTable: Bool = false
    /// Search filter
    lazy var searchFilter = PostSearchFilter()
    /// Previous search filter
    private var previousSearchFilter: PostSearchFilter?
    /// Timer for automatically triggering search based on user behavior. 
    /// Tying in search bar will reset timer and search bar will trigger searching once timer is expired.
    private var inputTimer: NSTimer?
    /// Flag to indicate whether we have more search results which haven't been got from server.
    private var hasMoreResults: Bool = false
    /// Table indexpath for selected post.
    private var selectedPostIndexPath: NSIndexPath?
    
    // MARK: Computed properties
    
    /// Array of posts to be displayed.
    var displayPosts: [Post] {
        get {
            if self.searchController.active {
                return self.searchResultPosts
            }
            else {
                return self.categoryPosts
            }
        }
        set {
            if self.searchController.active {
                self.searchResultPosts = newValue
            }
            else {
                self.categoryPosts = newValue
            }
        }
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = .None
        self.definesPresentationContext = false
        
        // Register nib
        self.postTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        
        // Initialize navigation bar
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(self.showSearchBar(_:)))
        self.composePostButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(self.composePost(_:)))
        self.navigationItem.rightBarButtonItems = [self.composePostButton, self.searchButton]
        
        // Initialize tab bar
        if let navigationController = self.navigationController {
            navigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: Constants.Post.Image.TabBarIcon?.imageWithRenderingMode(.AlwaysOriginal),
                                                           selectedImage: Constants.Post.Image.TabBarSelectedIcon?.imageWithRenderingMode(.AlwaysOriginal))
        }
        
        // Initialize tableview
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        //self.postTableView.estimatedRowHeight = 180
        //self.postTableView.rowHeight = UITableViewAutomaticDimension
        self.postTableView.tableFooterView = UIView(frame: CGRectZero)
        self.postTableView.separatorStyle = .None
        
        // Add components
        self.addSearchController()
        self.addRefreshControl()
        self.addDropdownList()
        self.addCurrentUserBanner()
        self.addNewPostNotificationView()
        self.addHamburgerMenuButton()
        
        // Add Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(HomeViewController.checkNewPosts),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(HomeViewController.reloadTable(_:)),
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
        self.loadSavedPosts()
        self.loadPosts()
    }
    
    deinit {
        // Remove notification observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Remove UISearchController
        self.searchController.view.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check new post notification
        self.showNewPostNotificationView()
        
        // Reset drop list
        self.addDropdownList()
        
        // Check launch data
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, postId = appDelegate.launchPostId {
            self.showPost(postId)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissInputView()
        self.dismissReachabilityError()
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
            if let postId = sender as? String {
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
            contactVC.contact = User(objectId: selectedUserId)
            contactVC.hidesBottomBarWhenPushed = true
        }
        
        if let newPostVC = segue.destinationViewController as? NewPostViewController where segue.identifier == "Compose Post" {
            newPostVC.hidesBottomBarWhenPushed = true
        }
        
        if let filterVC = segue.destinationViewController as? PostFilterViewController where segue.identifier == "Filter Post" {
            filterVC.searchFilter = self.searchFilter
            filterVC.delegate = self
        }
    }
    
    // MARK: UI functions
    
    /**
     Add search controller.
     */
    private func addSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.autocapitalizationType = .None
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.tintColor = Constants.General.Color.TitleColor
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.showsCancelButton = false
        self.searchController.automaticallyAdjustsScrollViewInsets = false
    }
    
    /**
     Add refresh controller to post table.
     */
    private func addRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(HomeViewController.loadPosts), forControlEvents: .ValueChanged)
        self.postTableView.addSubview(self.refreshControl)
    }
    
    /**
     Add dropdown list for post category.
     
     - Parameters:
        - updateOnly: only update dropdown list without adding it again.
     */
    private func addDropdownList() {
        // Initial a dropdown list with options
        let title = self.searchFilter.searchType.rawValue
        self.menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: title, items: PostSearchType.allTitles)
        
        // Set action closure
        self.menuView!.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            guard let searchType = PostSearchType.allTypes[safe: indexPath] else { return }
            
            switch searchType {
            case .All,
                 .Saved:
                self.searchFilter.searchType = searchType
                self.searchFilter.clearCustomFilter()
                self.loadPosts()
            case .Filter:
                self.performSegueWithIdentifier("Filter Post", sender: self)
            }
        }
        
        // Add the dropdown list to the navigation bar
        self.navigationItem.titleView = self.menuView
    }
    
    /**
     Add a banner view for current user.
     */
    private func addCurrentUserBanner() {
        // Set up banner
        self.currentUserBanner.backgroundColor = Constants.General.Color.LightBackgroundColor
        self.nameLabel.textColor = Constants.General.Color.TextColor
        self.nameLabel.font = Constants.Post.Font.ListCurrentUserBanner
        self.locationLabel.textColor = Constants.Post.Color.ListDetailText
        self.locationLabel.font = Constants.Post.Font.ListUserBanner
        
        // set current user data
        self.nameLabel.text = self.currentUser.nameDescription
        self.locationLabel.text = self.currentUser.location.description
        
        // Load avatar
        self.currentUser.loadAvatarThumbnail { (imageResult, imageError) -> Void in
            guard let image = imageResult where imageError == nil else { return }
            self.currentUserAvatarView.image = image
        }
        
        // Add gesture
        self.currentUserBanner.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: #selector(HomeViewController.editCurrentUserProfile(_:))))
        
        // Resize post table content inset to hold place for this banner
        self.postTableView.contentInset = UIEdgeInsets(top: self.currentUserBanner.frame.size.height,
                                                       left: 0,
                                                       bottom: 0,
                                                       right: 0)
        // Show the banner
        self.updateCurrentUserBanner()
    }
    
    /**
     Add a view to notify new posts.
     */
    private func addNewPostNotificationView() {
        self.newPostNotificationView.backgroundColor = Constants.General.Color.ThemeColor
        self.newPostLabel.textColor = UIColor.whiteColor()
        self.newPostLabel.font = Constants.Post.Font.ListCurrentUserBanner
        
        self.newPostNotificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reloadTable(_:))))
        
        self.newPostNotificationView.hidden = true // Hide as default
        
        self.view.addSubview(self.newPostNotificationView)
        self.newPostNotificationTopConstraint = self.newPostNotificationView.topAnchor.constraintEqualToAnchor(self.postTableView.topAnchor, constant: 16)
        self.newPostNotificationBottomConstraint = self.newPostNotificationView.topAnchor.constraintEqualToAnchor(self.currentUserBanner.bottomAnchor, constant: 16)
        NSLayoutConstraint(item: self.newPostNotificationView,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: self.postTableView,
                           attribute: .CenterX,
                           multiplier: 1.0,
                           constant: 0).active = true
    }
    
    /**
     Add a button to launch hamburger menu.
     */
    private func addHamburgerMenuButton() {
        guard let revealViewController = self.revealViewController() else { return }
        
        revealViewController.rearViewRevealOverdraw = 0
        revealViewController.rearViewRevealWidth = UIScreen.mainScreen().bounds.width
        let button = HamburgerMenuButton()
        button.delegate = revealViewController
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        // Add gesture
        self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
    
    /**
     Show new post notification view if needed.
     */
    private func showNewPostNotificationView() {
        if let labelWidth = self.newPostLabel.text?.widthWithConstrainedHeight(20, font: self.newPostLabel.font) {
            let width = labelWidth + 24 + 12
            self.newPostNotificationView.frame.size = CGSize(width: width, height: self.newPostNotificationView.frame.size.height)
        }
        
        self.newPostNotificationView.layer.cornerRadius = self.newPostNotificationView.frame.size.height / 2 // Issue in iOS 10, cornerRadisu does not work in ViewDidLoad, we should call it in viewDidAppear
        self.checkNewPosts()
    }
    
    /**
     Determine the UI status of current user banner based on table content offset and status of search bar.
     */
    private func updateCurrentUserBanner () {
        // Hide user banner if search is active
        if self.isShowingSearchBar {
            self.currentUserBanner.alpha = 0.0
            self.postTableView.contentInset = UIEdgeInsetsZero
            return
        }
        
        // Resize post table content inset to hold place for this banner
        self.postTableView.contentInset = UIEdgeInsets(top: self.currentUserBanner.frame.size.height,
                                                       left: 0,
                                                       bottom: 0,
                                                       right: 0)
        
        // Change the alpha of current user banner based on percentage of overlap between banner and table content
        let bannerHeight = self.currentUserBanner.frame.size.height
        let offset = self.postTableView.contentOffset
        let previousAlpha = self.currentUserBanner.alpha
        self.currentUserBanner.alpha = -offset.y / bannerHeight
        
        // Update new post notification constraint
        if previousAlpha > 0.0 && self.currentUserBanner.alpha <= 0.0 {
            self.updateNewPostNotificationConstraints()
        }
        else if previousAlpha <= 0.0 && self.currentUserBanner.alpha > 0.0 {
            self.updateNewPostNotificationConstraints()
        }
    }
    
    /**
     Update new post notification view's contraints.
     */
    private func updateNewPostNotificationConstraints() {
        guard let topConstraint = self.newPostNotificationTopConstraint,
            bottomConstraint = self.newPostNotificationBottomConstraint else { return }
        
        if self.currentUserBanner.alpha <= 0.0 {
            topConstraint.active = true
            bottomConstraint.active = false
        }
        else {
            topConstraint.active = false
            bottomConstraint.active = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    /**
     Show empty view for post table.
     */
    private func showEmptyView() {
        let emptyView = EmptyPostView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: self.postTableView.frame.size.width,
                                                    height: self.postTableView.frame.size.height))
        // Set message
        if self.searchFilter.searchString.isEmpty {
            if self.searchController.active {
                emptyView.text = "" // Don't show message if end-user is search results are displayed
            }
            else {
                emptyView.text = "Wumi has no post data"
            }
        }
        else {
            emptyView.text = "Sorry, no post was found with your searching words: \"\(self.searchFilter.searchString)\""
        }
        self.postTableView.backgroundView = emptyView
    }
    
    // MARK: Action
    
    /**
     Edit current user profile after tapping user banner view.
     
     - Parameters:
        - recognizer: tap gesture recognizer.
     */
    func editCurrentUserProfile(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Edit Profile", sender: recognizer.view)
    }
    
    /**
     Show contact after tapping an user's view.
     
     - Parameters:
        - recognizer: tap gesture recognizer.
     */
    func showContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    /**
     Show search bar after tapping navigation bar search item.
     
     - Parameters:
        - sender: navigation bar item.
     */
    func showSearchBar(sender: AnyObject) {
        self.isShowingSearchBar = true
        
        self.postTableView.tableHeaderView = self.searchController.searchBar // Add search bar to table header
        self.navigationItem.rightBarButtonItems?.removeObject(self.searchButton) // Hide right search navigation items
        
        // Hide current user banner
        self.updateCurrentUserBanner()
        
        self.postTableView.setContentOffset(CGPoint.zero, animated: true) // scroll table back to top to show the search bar
    }
    
    /**
     Compose a new post after tapping navigation bar compose item.
     
     - Parameters:
        - sender: navigation bar item.
     */
    func composePost(sender: AnyObject) {
        self.performSegueWithIdentifier("Compose Post", sender: self)
    }
    
    /**
     Reload post after tapping a component.
     
     - Parameters:
        - sender: navigation bar item.
     */
    func reloadTable(sender: AnyObject) {
        self.postTableView.setContentOffset(CGPoint(x: 0,
                                                        y: -self.refreshControl.frame.size.height - self.currentUserBanner.frame.size.height),
                                            animated:true)
        self.refreshControl.beginRefreshing()
        self.loadPosts()
    }
    
    /**
     Show a specific post.
     
     - Parameters:
        - sender: component triggers event.
     */
    func showPost(sender: AnyObject) {
        if let notification = sender as? NSNotification, postId = notification.object as? String where Post.findPost(objectId: postId) {
            self.performSegueWithIdentifier("Show Post", sender: postId)
        }
        if let postId = sender as? String where Post.findPost(objectId: postId) {
            self.performSegueWithIdentifier("Show Post", sender: postId)
        }
    }
    
    // MARK: Help function
    
    /**
     Check whether current user has new post to view or not.
     */
    func checkNewPosts() {
        // Do not show new post notification if end-users are actively searching results.
        guard self.searchController.active == false else { return }
        guard self.isLoadingPost == false else { return }
        
        guard let firstPost = self.displayPosts.first else { return }
        
        Post.countNewPosts(filter: self.searchFilter,
                           cutoffTime: firstPost.updatedAt,
                           user: self.currentUser) { (count, error) in
            guard error == nil else {
                self.view.sendSubviewToBack(self.newPostNotificationView)
                self.newPostNotificationView.hidden = true
                ErrorHandler.log(error)
                return
            }
                
            guard count > 0 else {
                self.view.sendSubviewToBack(self.newPostNotificationView)
                self.newPostNotificationView.hidden = true
                return
            }
                
            self.view.bringSubviewToFront(self.newPostNotificationView)
            self.newPostNotificationView.hidden = false
                
            self.updateNewPostNotificationConstraints()
        }
    }
    
    /**
     Load current user's saved posts asynchronously and update table if needed.
     */
    private func loadSavedPosts() {
        self.currentUser.loadSavedPosts { (posts, error) in
            guard error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            if posts.count > 0 {
                // Reload table
                self.postTableView.reloadData()
            }
        }
    }
    
    /**
     Load posts based on current searching criterias.
     */
    func loadPosts() {
        // Hide new post notification
        self.view.sendSubviewToBack(self.newPostNotificationView)
        self.newPostNotificationView.hidden = true
        
        // Start refreshing
        if !self.refreshControl.refreshing {
            self.showLoadingIndicator()
        }
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                       filter: self.searchFilter,
                       user: self.currentUser)
        { (posts, error) in
            // End refreshing
            self.dismissLoadingIndicator()
            self.refreshControl.endRefreshing()
            
            guard error == nil else {
                ErrorHandler.log(error)
                return
            }
                    
            self.displayPosts = posts
            self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
            self.previousSearchFilter = self.searchFilter
            
            self.postTableView.reloadData()
        }
    }
    
    /**
     Load more posts based on current searching criterias.
     */
    private func loadMorePosts() {
        guard let lastPost = self.displayPosts.last else { return }
        
        Post.loadPosts(limit: Constants.Query.LoadPostLimit,
                       filter: self.searchFilter,
                       cutoffTime: lastPost.updatedAt,
                       user: self.currentUser)
        { (posts, error) in
            guard error == nil else {
                ErrorHandler.log(error)
                return
            }
                    
            self.displayPosts.appendContentsOf(posts)
            self.hasMoreResults = posts.count == Constants.Query.LoadPostLimit
            self.previousSearchFilter = self.searchFilter
            
            if posts.count > 0 {
                self.postTableView.reloadData()
            }
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
            if self.isLoadingPost {
                self.showDefaultTable = true
                self.postTableView.userInteractionEnabled = false
                return 5
            }
            else {
                self.showDefaultTable = false
                self.postTableView.userInteractionEnabled = false
                self.showEmptyView()
            }
        }
        else {
            self.showDefaultTable = false
            self.postTableView.userInteractionEnabled = true
        }
        
        return self.displayPosts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Return height for default table cell
        guard !self.showDefaultTable else {
            return PostTableViewCell.fixedHeight
        }
        
        guard let post = self.displayPosts[safe: indexPath.row] else { return 0 }
        
        // Try get cached height
        if let cachedHeight = DataManager.sharedDataManager.cache.objectForKey("post_\(post.objectId)_cellHeight") as? CGFloat {
            return cachedHeight
        }
        
        var textHeight: CGFloat = 0.0
        var attributedString: NSAttributedString?
        if let attributedContent = post.attributedContent {
            attributedString = attributedContent
        }
        else if let content = post.content {
            attributedString = PostTableViewCell.attributedText(NSAttributedString(string: content))
        }
        
        if let content = attributedString {
            textHeight = TTTAttributedLabel.sizeThatFitsAttributedString(content,
                                                                         withConstraints: CGSize(width: tableView.contentSize.width, height: 400),
                                                                         limitedToNumberOfLines: 3).height
        }
        
        if post.hasThumbnail || post.hasPreviewImage {
            textHeight = max(textHeight, PostTableViewCell.fixedImagePreviewHeight)
        }
        
        let cellHeight = PostTableViewCell.fixedHeight + textHeight
        // Cache cell height
        if post.attributedContent != nil {
            DataManager.sharedDataManager.cache.setObject(cellHeight, forKey: "post_\(post.objectId)_cellHeight")
        }
        
        return cellHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let post = self.displayPosts[safe: indexPath.row] else { return }
        
        // Cache cell height again before displaying
        DataManager.sharedDataManager.cache.setObject(cell.frame.size.height, forKey: "post_\(post.objectId)_cellHeight")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        // Show default table
        guard !self.showDefaultTable else {
            cell.showDefault()
            return cell
        }
        
        guard let post = self.displayPosts[safe: indexPath.row] else {
            return cell
        }
        
        // Highlight searching string
        cell.highlightedString = self.searchFilter.searchString
        
        // Set title
        print(post.categories)
        if let title = post.title where !title.isEmpty {
            cell.title = title
        }
        else {
            cell.title = "No Title"
        }
        
        // Hide image preview if there is no thumbnail or url preview image.
        cell.hideImageView = !post.hasThumbnail && !post.hasPreviewImage
        
        // Set content
        if post.attributedContent != nil {
            cell.content = post.attributedContent
        }
        else {
            // Fetch content if needed
            post.loadContentWithBlock(requestPreviewImage: true) { (found, foundUrl) in
                // Reload cell if text changed
                if found {
                    self.postTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
        
        // Load preview image from attachment media or external URL
        if post.hasThumbnail {
            post.loadFirstThumbnailWithBlock { (result, error) in
                guard let image = result, cell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell where error == nil else {
                    ErrorHandler.log(error)
                    return
                }
                
                // Scale thumbnail to a new image with height 80.
                cell.previewImage = image.scaleToHeight(80)
            }
        }
        else if let url = post.externalPreviewImageUrl{
            cell.imagePreview.sd_setImageWithURL(url,
                                                 placeholderImage: UIImage(named: Constants.General.ImageName.Logo))
        }
        
        // Fetch author information
        if let author = post.author {
            author.loadIfNeededInBackgroundWithBlock { (result, error) in
                guard let user = result where error == nil else { return }
                
                cell.authorView.detailLabel.text = user.shortUserBannerDesc
                cell.authorView.userObjectId = user.objectId
                cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showContact(_:))))
                
                // Load avatar of author
                user.loadAvatarThumbnail { (imageResult, imageError) -> Void in
                    guard let image = imageResult where imageError == nil else {
                        // Show name initials
                        if let name = user.name {
                            cell.authorView.avatarImageView.showNameAvatar(name)
                        }
                        return
                    }
                    
                    cell.authorView.avatarImageView.image = image
                }
            }
        }
        
        // Set other components
        cell.timeStamp = post.updatedAt.timeAgo()
        cell.isSaved = self.currentUser.savedPostsArray.contains( { $0 == post} )
        cell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        
        // Set delegate
        cell.delegate = self
        
        // Preload post + 5
        if let preloadPost = self.displayPosts[safe: indexPath.row + 5] {
            preloadPost.fetchDataInBackground()
        }
        
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
        guard !self.isLoadingPost && self.hasMoreResults else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= (PostTableViewCell.fixedHeight + PostTableViewCell.fixedImagePreviewHeight) * 2 {
            self.loadMorePosts()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateCurrentUserBanner() // Update current user banner
    }
}

// MARK: Search delegate

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isShowingSearchBar = false
        
        self.navigationItem.rightBarButtonItems?.append(self.searchButton) // Add right search navigation items back
        self.postTableView.tableHeaderView = nil // Remove search bar from table header
        
        // Show user banner if possible
        self.updateCurrentUserBanner()
        
        self.postTableView.setContentOffset(CGPoint(x: 0,
                                                    y: -self.currentUserBanner.frame.size.height),
                                            animated: true)
        
        // Reset search string
        self.searchFilter.searchString = ""
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Try search results if there is a pause when typing
        self.triggerTextSearch(searchController.searchBar.text, useTimer: true)
    }
    
    /**
     Trigger a text search.
     
     - Parameters:
        - searchBarText: text string filled in search bar.
        - useTimer: Whether to use timer for automatical search or not.
     */
    private func triggerTextSearch(searchBarText: String?, useTimer: Bool) {
        // Stop current running timer from run loop on main queue
        self.stopTimer()
        
        if let searchInput = searchBarText where !searchInput.isEmpty {
            // Quit if there is no change in the search string
            guard searchInput != self.previousSearchFilter?.searchString else { return }
            
            self.searchFilter.searchString = searchInput
            
            // Start an instant search or start delay timer
            if useTimer {
                self.startTimer() // start the timer if we are using timer
            }
            else {
                self.loadPosts() // search instantly if we are not using timer
            }
        }
        else {
            self.searchResultPosts.removeAll(keepCapacity: false)
            self.postTableView.reloadData()
        }
    }
    
    /**
     Start the search timer.
     */
    private func startTimer() {
        dispatch_async(dispatch_get_main_queue()) { () in
            // start a new timer
            self.inputTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Query.searchTimeInterval,
                                                                     target: self,
                                                                     selector: #selector(self.loadPosts),
                                                                     userInfo: nil,
                                                                     repeats: false)
        }
    }
    
    /**
     Stop the search timer.
     */
    private func stopTimer() {
        dispatch_async(dispatch_get_main_queue()) { () in
            // Stop input timer if one is running
            guard let timer = self.inputTimer else { return }
            
            timer.invalidate()
        }
    }
}

// MARK: Favorite button delegate

extension HomeViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.postTableView)
        guard let indexPath = self.postTableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell,
            post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.savePost(post) { (success, error) in
            guard success && error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            cell.isSaved = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        let buttonPosition = favoriteButton.convertPoint(CGPointZero, toView: self.postTableView)
        guard let indexPath = self.postTableView.indexPathForRowAtPoint(buttonPosition),
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell,
            post = self.displayPosts[safe: indexPath.row] else { return }
        
        self.currentUser.unsavePost(post) { (success, error) in
            guard success && error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            cell.isSaved = false
            
            // Remove cell if we are on the Saved Search Type which should only show saved posts
            if self.searchFilter.searchType == .Saved {
                self.displayPosts.removeObject(post)
                self.postTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
}

// MARK: Reply button delegate

extension HomeViewController: ReplyButtonDelegate {
    func reply(replyButton: ReplyButton) {
        self.performSegueWithIdentifier("Show Post", sender: replyButton)
    }
}

// MARK: TTTAttributeLabel delegate

extension HomeViewController: TTTAttributedLabelDelegate {
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        // Launch application if it can be handled by any app installed
        if url.willOpenInApp != nil {
            UIApplication.sharedApplication().openURL(url)
        }
        // Otherwise, request it in web viewer
        else {
            let webVC = WebFullScreenViewController()
            webVC.url = url
            
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
}

// MARK: PostViewController delegate

extension HomeViewController: PostViewControllerDelegate {
    func finishViewPost(postVC: PostViewController) {
        guard let indexPath = self.selectedPostIndexPath,
            cell = self.postTableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell else { return }
        
        cell.isSaved = postVC.isSaved
    }
    
    func deletePost(postVC: PostViewController) {
        guard let indexPath = self.selectedPostIndexPath else { return }
        
        self.displayPosts.removeAtIndex(indexPath.row)
        self.postTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}

// MARK: PostFilterViewController delegate

extension HomeViewController: PostFilterViewControllerDelegate {
    func startFilterSearch(filterVC: PostFilterViewController) {
        self.searchFilter = filterVC.searchFilter
        self.loadPosts()
    }
}
