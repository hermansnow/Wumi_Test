//
//  PostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import KIImagePager
import TSMessages

class PostViewController: UITableViewController {
    
    var replyView: ReplyTextView!
    private lazy var replyButton = UIBarButtonItem()
    private lazy var cancelButton = UIBarButtonItem()
    private lazy var sendButton = UIBarButtonItem()
    private lazy var maskView = UIView()
    private lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private lazy var emptyView = EmptyCommentView(frame: CGRect(x: 0, y: 0, width: 100, height: 20)) // Show header for empty data
    
    var delegate: PostViewControllerDelegate?
    
    var currentUser = User.currentUser()
    var post: Post?
    var postCell: PostContentCell!
    var postAttributedContent: NSAttributedString?
    var replyComment: Comment? = nil
    lazy var comments: [Comment]? = nil
    
    var isSaved: Bool = false
    var launchReply: Bool = false
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "PostContentCell", bundle: nil), forCellReuseIdentifier: "PostContentCell")
        self.tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        // Add notification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PostViewController.keyboardWillShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PostViewController.keyboardWillHiden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = Constants.General.Color.LightBackgroundColor
        self.tableView.separatorStyle = .None
        
        // Initialize navigation bar
        self.replyButton = UIBarButtonItem(title: "Reply", style: .Done, target: self, action: #selector(replyPost(_:)))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelReply(_:)))
        self.sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: #selector(sendReply(_:)))
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Add reply view
        self.addReplyView()
        
        // Load the post
        self.loadPost()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Launch reply if needed
        if self.launchReply {
            self.replyPost(self)
        }
        self.launchReply = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissReachabilityError()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let delegate = self.delegate where parent == nil {
            delegate.finishViewPost(self)
        }
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostViewController.loadPost), forControlEvents: .ValueChanged)
    }
    
    private func addReplyView() {
        guard let view = NSBundle.mainBundle().loadNibNamed("ReplyTextView", owner: self, options: nil).first as? ReplyTextView else { return }
        
        view.frame = CGRect(x: 0, y: self.view.frame.height - 170, width: self.view.frame.width, height: 170)
        self.replyView = view
        
        // Load current user's data
        self.currentUser.loadAvatarThumbnail() { (result, error) -> Void in
            guard error == nil else { return }
            self.replyView.myAvatarView.image = result
        }
        
        // Initialize mask view
        self.maskView.frame = self.view.frame
        self.maskView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        self.maskView.userInteractionEnabled = true
        self.maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.cancelReply(_:))))
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
            return self.comments != nil ? self.comments!.count : 0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            if self.comments == nil && self.loadingView.animating {
                self.loadingView.frame.origin = CGPoint(x: self.tableView.frame.size.width / 2 - 10, y: 20) // Show loading view
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60))
                headerView.addSubview(self.loadingView)
                return headerView
            }
            else if self.comments != nil && self.comments!.count == 0 {
                self.emptyView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60) // Show empty view
                return self.emptyView
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            if self.comments == nil && self.loadingView.animating {
                return 60
            }
            else if self.comments != nil && self.comments!.count == 0 {
                return 60
            }
            else {
                return 0
            }
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
    
    private func cellForPost(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PostContentCell {
        self.postCell = tableView.dequeueReusableCellWithIdentifier("PostContentCell", forIndexPath: indexPath) as! PostContentCell
        
        self.postCell.reset()
        
        guard let post = self.post else { return self.postCell }
        
        if let title = post.title where title.characters.count > 0 {
            self.postCell.title = title
        }
        else {
            self.postCell.title = "No Title"
        }
        
        self.postCell.content = post.content
        
        if post.mediaThumbnails.count > 0 {
            self.postCell.hideImageView = false
            self.postCell.imagePager.reloadData()
        }
        else {
            self.postCell.hideImageView = true
        }
        
        self.postCell.timeStamp = post.updatedAt.timeAgo()
        self.postCell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        
        self.postCell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.showUserContact(_:))))
        
        if let author = post.author {
            author.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                guard let user = result as? User where error == nil else { return }
                
                self.postCell.authorView.detailLabel.text = user.nameDescription + (user.location.description.characters.count > 0 ? ", " + user.location.description : "")
                self.postCell.authorView.userObjectId = user.objectId
            
                user.loadAvatarThumbnail { (imageResult, imageError) -> Void in
                    guard let image = imageResult where imageError == nil else { return }
                    self.postCell.authorView.avatarImageView.image = image
                }
            }
        }
        
        self.postCell.isSaved = self.currentUser.savedPostsArray.contains(post)
        
        self.postCell.selectionStyle = .None
        
        self.postCell.delegate = self
        
        return self.postCell
    }
    
    private func cellForReply(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CommentTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentTableViewCell", forIndexPath: indexPath) as! CommentTableViewCell
        
        //cell.reset()
        
        guard let comments = self.comments, comment = comments[safe: indexPath.row] else { return cell }
        
        if let content = comment.content {
            if let reply = comment.reply, replyToUser = reply.author, name = replyToUser.name {
                cell.content = "Reply to \(name): \(content)"
            }
            else {
                cell.content = content
            }
        }
        cell.contentTextView.parentCell = cell
        cell.contentTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.replyComment(_:))))
        
        cell.timeStamp = comment.createdAt.timeAgo()
        
        cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.showUserContact(_:))))
        
        if let author = comment.author {
            author.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                guard let user = result as? User where error == nil else { return }
                cell.authorView.detailLabel.text = user.name
                cell.authorView.userObjectId = user.objectId
            
                user.loadAvatarThumbnail { (imageResult, imageError) -> Void in
                    guard let image = imageResult where imageError == nil else { return }
                    cell.authorView.avatarImageView.image = image
                }
            }
        }
        
        cell.selectionStyle = .None
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: ScrollView delegete
    
    // Load more users when dragging to bottom
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let tableview = scrollView as? UITableView where self.refreshControl != nil && !self.refreshControl!.refreshing else { return }
        
        // UITableView only moves in one direction, y axis
        let currentOffset = tableview.contentOffset.y;
        let maximumOffset = tableview.contentSize.height - tableview.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.loadMoreComments()
        }
    }
    
    // MARK: Actions
    func replyPost(sender: AnyObject) {
        UIApplication.sharedApplication().delegate?.window!!.addSubview(self.replyView)
        self.replyView.commentTextView.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.replyView.reset()
        self.replyComment = nil
    }
    
    func replyComment(recognizer: UITapGestureRecognizer) {
        
        guard let contentLabel = recognizer.view as? CommentTextView else { return }
        guard let commentCell = contentLabel.parentCell,
            indexPath = tableView.indexPathForCell(commentCell),
            comments = self.comments,
            selectedComment = comments[safe: indexPath.row] else { return }
        
        self.replyView.reset()
        self.replyComment = selectedComment
        if let name = selectedComment.author?.name {
            self.replyView.commentTextView.placeholder = "Reply to: \(name)"
        }
        
        UIApplication.sharedApplication().delegate?.window!!.addSubview(self.replyView)
        self.replyView.commentTextView.becomeFirstResponder()
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.sendButton
    }
    
    func cancelReply(sender: AnyObject) {
        self.replyView.commentTextView.resignFirstResponder()
        
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
    }
    
    func sendReply(sender: AnyObject) {
        guard self.replyView.commentTextView.text.characters.count > 0 else {
            Helper.PopupErrorAlert(self, errorMessage: "Cannot send blank comment") { (action) -> Void in
                self.replyView.commentTextView.becomeFirstResponder()
            }
            return
        }
        
        self.replyView.removeFromSuperview()
        
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
        
        guard let post = self.post else { return }
        
        Comment.sendNewCommentForPost(post, author: self.currentUser, content: self.replyView.commentTextView.text, replyComment: replyComment) { (success, error) -> Void in
            guard success && error == nil else {
                print("\(error)")
                return
            }
            
            self.postCell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
            self.loadComments()
        }
        
        // send push notification to users that saved this post 
        post.loadFavoriteUsers { (results, error) in
            guard let users = results as? [User] where error == nil else { return }
            
            for user in users
            {
                if(!(user == self.currentUser))
                {
                    PushNotification(fromUser: self.currentUser, toUser: user, post: post, isPostAuthor: false).sendPushForPost(self)
                }
            }
        }
        
        // send push notification to the author of this post
        guard let toUser = post.author else { return }
        if(toUser == self.currentUser) {return}
        PushNotification(fromUser: self.currentUser, toUser: toUser, post: post, isPostAuthor: true).sendPushForPost(self)
    }
    
    func showUserContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    // Pop up comment view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        if let commentTextView = UIResponder.currentFirstResponder() as? PostTextView where commentTextView == self.replyView.commentTextView {
            var visibleRect = UIApplication.sharedApplication().delegate?.window!!.frame
            visibleRect!.size.height -= keyboardRect.size.height
            self.replyView.frame.origin.y = visibleRect!.size.height - self.replyView.frame.size.height
            self.view.addSubview(maskView)
        }
    }
    
    // Hide comment view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        if let commentTextView = UIResponder.currentFirstResponder() as? PostTextView where commentTextView == self.replyView.commentTextView {
            self.replyView.frame.origin.y = (UIApplication.sharedApplication().delegate?.window!!.frame.height)!
            self.maskView.removeFromSuperview()
        }
    }
    
    // MARK: Help function
    func loadPost() {
        guard let post = self.post else { return }
        
        Post.fetchInBackground(objectId: post.objectId) { (result, error) in
            guard let post = result as? Post where error == nil else { return }
            
            self.post = post
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            
            // Load comments
            self.loadComments()
            
            // End the refreshing
            if let refreshControl = self.refreshControl {
                refreshControl.endRefreshing()
            }
        }

    }
    
    func loadComments() {
        guard let post = self.post else { return }
        
        self.comments = nil
        self.loadingView.startAnimation()
        UIView.performWithoutAnimation { () -> Void in
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
        
        Comment.loadRepliesForPost(post) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let comments = results as? [Comment] else {
                self.comments = [Comment]()
                self.loadingView.stopAnimation()
                return
            }
            
            self.comments = comments
            
            // Stop loading view
            self.loadingView.stopAnimation()
            
            // Disable animation for displaying comment list
            UIView.performWithoutAnimation { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
    
    func loadMoreComments() {
        guard let post = self.post else { return }
        
        let currentCount = self.comments != nil ? self.comments!.count : 0
        Comment.loadRepliesForPost(post, skip: currentCount) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            guard let comments = results as? [Comment] where comments.count > 0 else { return }
            
            if self.comments != nil {
                self.comments!.appendContentsOf(comments)
            }
            else {
                self.comments = comments
            }
            
            // Disable animation for displaying comment list
            UIView.performWithoutAnimation { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
}

// MARK: KIImagePager delegate

extension PostViewController: KIImagePagerDataSource {
    func arrayWithImages(pager: KIImagePager!) -> [AnyObject]! {
        guard let post = self.post else { return [] }
        
        return  post.attachedImages
    }
    
    func contentModeForImage(image: UInt, inPager pager: KIImagePager!) -> UIViewContentMode {
        return .ScaleAspectFill
    }
}

extension PostViewController: KIImagePagerDelegate {
    func imagePager(imagePager: KIImagePager!, didSelectImageAtIndex index: UInt) {
        guard let post = self.post else { return }

        let imagePageVC = ImageFullScreenViewController()
        imagePageVC.images = post.attachedImages
        imagePageVC.currentIndex = Int(index)
        imagePageVC.enableSaveImage = true
        
        imagePageVC.modalTransitionStyle = .CrossDissolve
        imagePageVC.modalPresentationStyle = .FullScreen
        
        self.presentViewController(imagePageVC, animated: true, completion: nil)
    }
}

// MARK: UITextView delegate
extension PostViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        // Launch application if it can be handled by any app installed
        if URL.willOpenInApp() {
            UIApplication.sharedApplication().openURL(URL)
        }
        // Otherwise, request it in web viewer
        else {
            let webVC = WebFullScreenViewController()
            webVC.url = URL
        
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        return false
    }
}

// MARK: FavoriteButton delegate

extension PostViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        
        self.currentUser.savePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.postCell.isSaved = true
            self.isSaved = true
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        
        self.currentUser.unsavePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.postCell.isSaved = false
            self.isSaved = false
        }
    }
}

// MARK: ReplyButtonDelegate

extension PostViewController: ReplyButtonDelegate {
    func reply(replyButton: ReplyButton) {
        self.replyPost(self)
    }
}

// MARK: ContactViewController delegate

extension PostViewController: ContactViewControllerDelegate {
    func finishViewContact(contactViewController: ContactViewController) {
        return
    }
}

// MARK: PostViewControllerDelegate

protocol PostViewControllerDelegate {
    func finishViewPost(postVC: PostViewController)
}

