//
//  PostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostViewController: UITableViewController {
    
    @IBOutlet weak var myUserBannerView: UserBannerView!
    @IBOutlet weak var commentTextView: PostTextView!
    @IBOutlet weak var commentView: UIView!
    
    lazy var replyButton = UIBarButtonItem()
    lazy var cancelButton = UIBarButtonItem()
    lazy var sendButton = UIBarButtonItem()
    lazy var maskView = UIView()
    
    var delegate: PostViewControllerDelegate?
    
    var currentUser = User.currentUser()
    var post: Post?
    var updatedAtDateFormatter = NSDateFormatter()
    lazy var comments = [Comment]()
    
    var isSaved: Bool = false
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        self.tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHiden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.maskView.frame = self.view.frame
        self.maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.78)
        
        
        // Initialize navigation bar
        self.replyButton = UIBarButtonItem(title: "Reply", style: .Done, target: self, action: "replyPost:")
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelReply:")
        self.sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: "sendReply:")
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
        
        // Initialize comment subview
        self.commentView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 160)
        self.commentTextView.characterLimit = 300  // Limitation for lenght of comment
        self.currentUser.loadAvatar(ScaleToSize: CGSize(width: 20, height: 20)) { (result, error) -> Void in
            guard error == nil else { return }
            self.myUserBannerView.avatarImageView.image = result
        }
        self.myUserBannerView.detailLabel.text = self.currentUser.name
        self.myUserBannerView.backgroundColor = Constants.General.Color.BackgroundColor
        
        self.updatedAtDateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Load posts
        self.loadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let delegate = self.delegate where parent == nil {
            delegate.finishViewPost(self)
        }
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("loadData"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contactVC = segue.destinationViewController as? ContactViewController where segue.identifier == "Show Contact" {
            guard let view = sender as? UserBannerView, selectedUserId = view.userObjectId else { return }
            contactVC.delegate = self
            contactVC.selectedUserId = selectedUserId
            contactVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.comments.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return self.cellForPost(tableView, cellForRowAtIndexPath: indexPath)
        case 1:
            return cellForReply(tableView, cellForRowAtIndexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
        
    private func cellForPost(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MessageTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        guard let post = self.post else { return cell }
        
        if let title = post.title {
            cell.title = NSMutableAttributedString(string: title)
        }
        if let content = post.content {
            cell.content = NSMutableAttributedString(string: content)
        }
        cell.showSummary = false
        cell.timeStamp = "Last updated at: " + self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
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
        
        self.isSaved = self.currentUser.savedPostsArray.contains(post)
        cell.saveButton.delegate = self
        cell.saveButton.selected = self.isSaved
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    private func cellForReply(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CommentTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentTableViewCell", forIndexPath: indexPath) as! CommentTableViewCell
        
        guard let comment = self.comments[safe: indexPath.row] else { return cell }
        
        cell.contentLabel.text = comment.content
        cell.timeStampLabel.text = self.updatedAtDateFormatter.stringFromDate(comment.createdAt)
        
        comment.author?.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            
            cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showUserContact:"))
            
            cell.authorView.detailLabel.text = user.name
            cell.authorView.userObjectId = user.objectId
            
            user.loadAvatar { (imageResult, imageError) -> Void in
                guard let image = imageResult where imageError == nil else { return }
                cell.authorView.avatarImageView.image = image
            }
        }
        
        cell.selectionStyle = .None
        
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
            self.loadMoreComments()
        }
    }
    
    // MARK: Actions
    func replyPost(sender: AnyObject) {
        UIApplication.sharedApplication().delegate?.window!!.addSubview(self.commentView)
        self.commentTextView.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.sendButton
    }
    
    func cancelReply(sender: AnyObject) {
        self.commentView.removeFromSuperview()
        
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
    }
    
    func sendReply(sender: AnyObject) {
        guard self.commentTextView.text.characters.count > 0 else {
            Helper.PopupErrorAlert(self, errorMessage: "Cannot send blank comment") { (action) -> Void in
                self.commentTextView.becomeFirstResponder()
            }
            return
        }
        
        self.commentView.removeFromSuperview()
        
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
        
        guard let post = self.post else { return }
        
        Comment.sendNewCommentForPost(post, author: self.currentUser, content: self.commentTextView.text) { (success, error) -> Void in
            guard success && error == nil else {
                print("\(error)")
                return
            }
            self.loadData()
        }
    }
    
    func showUserContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    // Pop up comment view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        if let commentTextView = UIResponder.currentFirstResponder() as? PostTextView where commentTextView == self.commentTextView {
            var visibleRect = UIApplication.sharedApplication().delegate?.window!!.frame
            visibleRect!.size.height -= keyboardRect.size.height
            self.commentView.frame.origin.y = visibleRect!.size.height - self.commentView.frame.size.height
            self.view.addSubview(maskView)
            self.tableView.userInteractionEnabled = false
        }
    }
    
    // Hide comment view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        if let commentTextView = UIResponder.currentFirstResponder() as? PostTextView where commentTextView == self.commentTextView {
            self.commentView.frame.origin.y = (UIApplication.sharedApplication().delegate?.window!!.frame.height)!
            self.maskView.removeFromSuperview()
            self.tableView.userInteractionEnabled = true
        }
    }
    
    // MARK: Help function
    func loadData() {
        guard let post = self.post else { return }
        
        post.fetchInBackgroundWithBlock { (result, error) -> Void in
            guard error == nil else { return }
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
        self.loadComments()
    }
    
    func loadComments() {
        guard let post = self.post else { return }
        
        Comment.loadRepliesForPost(post) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let comments = results as? [Comment] where comments.count > 0 else { return }
            
            self.comments = comments
            
            // Disable animation for displaying comment list
            UIView.performWithoutAnimation { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
    
    func loadMoreComments() {
        guard let post = self.post else { return }
        
        Comment.loadRepliesForPost(post, skip: self.comments.count) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let comments = results as? [Comment] where comments.count > 0 else { return }
            
            self.comments.appendContentsOf(comments)
            
            // Disable animation for displaying comment list
            UIView.performWithoutAnimation { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
}

extension PostViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        self.currentUser.savePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isSaved = true
            favoriteButton.selected = self.isSaved
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        self.currentUser.unsavePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isSaved = false
            favoriteButton.selected = self.isSaved
        }
    }
}

extension PostViewController: ContactViewControllerDelegate {
    func finishViewContact(contactViewController: ContactViewController) {
        return
    }
}

// MARK: Custome delegate

protocol PostViewControllerDelegate {
    func finishViewPost(postVC: PostViewController)
}

