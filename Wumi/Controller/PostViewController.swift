//
//  PostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import KIImagePager

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
    var postAttributedContent: NSAttributedString?
    var replyComment: Comment? = nil
    var updatedAtDateFormatter = NSDateFormatter()
    lazy var comments = [Comment]()
    
    var isSaved: Bool = false
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "PostContentCell", bundle: nil), forCellReuseIdentifier: "PostContentCell")
        self.tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(PostViewController.keyboardWillShown(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(PostViewController.keyboardWillHiden(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.maskView.frame = self.view.frame
        self.maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.78)
        
        // Initialize navigation bar
        self.replyButton = UIBarButtonItem(title: "Reply", style: .Done, target: self, action: #selector(replyPost(_:)))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelReply(_:)))
        self.sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: #selector(sendReply(_:)))
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.replyButton
        
        // Initialize comment subview
        self.commentView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 160)
        self.commentTextView.characterLimit = 300  // Limitation for lenght of comment
        self.currentUser.loadAvatarThumbnail() { (result, error) -> Void in
            guard error == nil else { return }
            self.myUserBannerView.avatarImageView.image = result
        }
        self.myUserBannerView.detailLabel.text = self.currentUser.name
        self.myUserBannerView.backgroundColor = Constants.General.Color.BackgroundColor
        
        self.updatedAtDateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Load the post
        self.loadPost()
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
        self.refreshControl!.addTarget(self, action: #selector(PostViewController.loadPost), forControlEvents: .ValueChanged)
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
    
        
    private func cellForPost(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PostContentCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostContentCell", forIndexPath: indexPath) as! PostContentCell
        
        guard let post = self.post else { return cell }
        
        if let title = post.title {
            cell.title = NSMutableAttributedString(string: title)
        }
        
        if let content = post.content {
            cell.content = NSMutableAttributedString(string: content)
        }
        
        if post.mediaThumbnails.count > 0 {
            cell.hideImageView = false
            cell.imagePager.dataSource = self
        }
        else {
            cell.hideImageView = true
        }
        
        cell.timeStamp = "Last updated at: " + self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
        cell.repliesButton.setTitle("\(post.commentCount) replies", forState: .Normal)
        
        cell.authorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.showUserContact(_:))))
        
        if let author = post.author {
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
        
        self.isSaved = self.currentUser.savedPostsArray.contains(post)
        cell.saveButton.delegate = self
        cell.saveButton.selected = self.isSaved
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    private func cellForReply(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CommentTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentTableViewCell", forIndexPath: indexPath) as! CommentTableViewCell
        
        guard let comment = self.comments[safe: indexPath.row] else { return cell }
        
        if let replyToUser = comment.reply?.author?.name {
            let content = comment.content!
            cell.contentLabel.text = "Reply to \(replyToUser): \(content)"
        } else {
            cell.contentLabel.text = comment.content
        }
        
        cell.timeStampLabel.text = self.updatedAtDateFormatter.stringFromDate(comment.createdAt)
        
        cell.contentLabel.parentCell = cell
        cell.contentLabel.userInteractionEnabled = true
        cell.contentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostViewController.replyComment(_:))))
        
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
        UIApplication.sharedApplication().delegate?.window!!.addSubview(self.commentView)
        self.commentTextView.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.commentTextView.text = ""
        self.replyComment = nil
        self.commentTextView.placeholder = ""
    }
    
    func replyComment(recognizer: UITapGestureRecognizer) {
        
        guard let contentLabel = recognizer.view as? CommentTextLabel else { return }
        guard let commentCell = contentLabel.parentCell, indexPath = tableView.indexPathForCell(commentCell),
            selectedComment = self.comments[safe: indexPath.row] else { return }
        
        self.commentTextView.text = ""
        self.replyComment = selectedComment
        if let name = selectedComment.author?.name {
            self.commentTextView.placeholder = "Reply to: \(name)"
        } else {
            self.commentTextView.placeholder = ""
        }
        
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
        
        Comment.sendNewCommentForPost(post, author: self.currentUser, content: self.commentTextView.text, replyComment: replyComment) { (success, error) -> Void in
            guard success && error == nil else {
                print("\(error)")
                return
            }
            self.loadPost()
        }
        
        // send push notification to users that saved this post
        for user in post.favoriteUsers
        {
            if(!(user == self.currentUser))
            {
                sendPushForPost(post, toUser:user, isPostAuthor: false)
            }
        }
        
        // send push notification to the author of this post
        guard let toUser = post.author else { return }
        if(toUser == self.currentUser) {return}
        sendPushForPost(post, toUser: toUser, isPostAuthor: true)
    }
    
    func showUserContact(recognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("Show Contact", sender: recognizer.view)
    }
    
    func sendPushForPost(post: Post, toUser: User, isPostAuthor: Bool)
    {
        let pushNotification = PushNotification.init(fromUser: self.currentUser, toUser: toUser, post: post, isPostAuthor: isPostAuthor)
        
        pushNotification.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                // Create our Installation query
                let pushQuery = AVInstallation.query()
                pushQuery.whereKey("owner", equalTo: pushNotification.toUser);
                let pushMiddleMessage = isPostAuthor ? " replied to your post " : " replied to your saved post "
                
                let data: [NSObject : AnyObject] = [
                    "alert" : self.currentUser.name! + pushMiddleMessage + post.title!,
                    "badge" : "Increment"
                ]
                
                let push: AVPush = AVPush()
                AVPush.setProductionMode(false)
                push.setQuery(pushQuery)
                push.setData(data)
                push.sendPushInBackground()
            }
        }
    }
    
    func showImage(recognizer: UITapGestureRecognizer) {
        guard let textView = recognizer.view as? UITextView else { return }
        
        // Location of the tap in text-container coordinates
        let layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        // Find the character that's been tapped on
        let characterIndex = layoutManager.characterIndexForPoint(location,
                                                                  inTextContainer: textView.textContainer,
                                                                  fractionOfDistanceBetweenInsertionPoints: nil)
        if (characterIndex < textView.textStorage.length) {
            if let attachment = textView.attributedText.attribute(NSAttachmentAttributeName, atIndex: characterIndex, effectiveRange: nil) as? NSTextAttachment{
                var image: UIImage?
                if attachment.image != nil {
                    image = attachment.image
                }
                else {
                    image = attachment.imageForBounds(attachment.bounds,
                                                      textContainer: nil,
                                                      characterIndex: characterIndex)
                }
                if image != nil {
                    let imageCropper = PIKAImageCropViewController()
                    
                    imageCropper.image = image
                    imageCropper.cropType = .Rect
                    let cropperWidth = self.view.bounds.width
                    imageCropper.cropRectSize = CGSize(width: cropperWidth, height: cropperWidth / CGFloat(Constants.General.Size.AvatarImage.WidthHeightRatio))
                    imageCropper.backgroundColor = Constants.General.Color.BackgroundColor
                    imageCropper.themeColor = Constants.General.Color.ThemeColor
                    imageCropper.titleColor = Constants.General.Color.TitleColor
                    imageCropper.maskColor = Constants.General.Color.DarkMaskColor
                    
                    self.presentViewController(imageCropper, animated: true, completion: nil)
                }
            }
        }
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
    func loadPost() {
        guard let post = self.post else { return }
        
        Post.fetchInBackground(objectId: post.objectId) { (result, error) in
            guard let post = result as? Post where error == nil else { return }
            
            self.post = post
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            self.loadComments()
        }

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

// MARK: KIImagePager delegate

extension PostViewController: KIImagePagerDataSource {
    func arrayWithImages(pager: KIImagePager!) -> [AnyObject]! {
        guard let post = self.post else { return [] }
        
        return  post.attachedThumbnails
    }
    
    func contentModeForImage(image: UInt, inPager pager: KIImagePager!) -> UIViewContentMode {
        return .ScaleAspectFit
    }
}

// MARK: FavoriteButton delegate

extension PostViewController: FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        self.currentUser.savePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isSaved = true
            favoriteButton.selected = self.isSaved
            post.favoriteUsers.appendUniqueObject(self.currentUser)
            post.saveInBackground()
        }
    }
    
    func removeFavorite(favoriteButton: FavoriteButton) {
        guard let post = self.post else { return }
        self.currentUser.unsavePost(post) { (result, error) -> Void in
            guard result && error == nil else { return }
            
            self.isSaved = false
            favoriteButton.selected = self.isSaved
            post.favoriteUsers.removeObject(self.currentUser)
            post.saveInBackground()
        }
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

