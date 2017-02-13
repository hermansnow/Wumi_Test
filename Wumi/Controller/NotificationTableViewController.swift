//
//  NotificationTableViewController.swift
//  Wumi
//
//  Created by Guang Han on 4/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import FormatterKit
import HexColors

class NotificationTableViewController: DataLoadingTableViewController {
    /// Current login user.
    private lazy var currentUser = User.currentUser()
    /// An array of pushed notifications.
    private lazy var pushNotifications = [PushNotification]()
    
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add tab bar item
        if let navigationController = self.navigationController {
            navigationController.tabBarItem = UITabBarItem(title: "Notification", image: Constants.Notification.Image.TabBarIcon,  tag: 1)
        }
        
        // Load badge
        self.updatePushNotificationBadge()
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
        // Initialize tableview
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorColor = UIColor.init(hexString: "#D5D5D5")
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        // Add Refresh Control
        self.addRefreshControl()
        
        // Load data
        self.loadPushNotifications()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postVC = segue.destinationViewController as? PostViewController where segue.identifier == "Show Post" {
            
            guard let cell = sender as? UITableViewCell else { return }
            guard let indexPath = tableView.indexPathForCell(cell) else { return }
            let pushNotification = self.pushNotifications[indexPath.row]
            let post = Post.query().getObjectWithId(pushNotification.post!.objectId) as? Post
            postVC.post = post
                       
            }
    }
    
    // MARK: UI Functions
    
    /**
     Set up refresh controller for the table view. Allow pull-to-refresh.
     */
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(self.loadPushNotifications), forControlEvents: .ValueChanged)
        }
    }
    
    // MARK: Helper functions
    
    /**
     Update the tab badge with the number of new notifications.
     */
    func updatePushNotificationBadge() {
        PushNotification.hasNewPushNotification(self.currentUser) { (count, error) in
            guard let navigationController = self.navigationController where error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            if count > 0 {
                navigationController.tabBarItem.badgeValue = "\(count)"
            }
            else {
                navigationController.tabBarItem.badgeValue = nil
            }
        }
    }
    
    /**
     Load and display all new notifications.
     */
    func loadPushNotifications() {
        // Clean current data
        self.pushNotifications.removeAll()
        
        // Start loading indicator if no running refresh controller
        if self.refreshControl?.refreshing == false {
            self.showLoadingIndicator()
        }
    
        // Load data
        PushNotification.loadPushNotifications(self.currentUser) { (results, error) -> Void in
            self.refreshControl?.endRefreshing()
            self.dismissLoadingIndicator()
            
            guard let notifications = results where error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            self.pushNotifications = notifications
            // Update badge number
            if let navigationController = self.navigationController {
                if self.pushNotifications.count > 0 {
                    navigationController.tabBarItem.badgeValue = "\(notifications.count)"
                }
                else {
                    navigationController.tabBarItem.badgeValue = nil
                }
            }
    
            // Reload table data
            self.tableView.reloadData()
        }
    }
    
    // MARK: TableView delegate & data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pushNotifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: NotificationTableViewCell
        if let dequeueCell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as? NotificationTableViewCell {
            cell = dequeueCell
        }
        else {
            cell = NotificationTableViewCell()
        }
        
        guard let pushNotification = self.pushNotifications[safe: indexPath.row] else {
            return cell
        }
        
        if let fromUser = pushNotification.fromUser, fromUserName = fromUser.name, post = pushNotification.post {
            
            var postTitle: String
            if let title = post.title where !title.isEmpty {
                postTitle = title
            }
            else {
                postTitle = "No Title"
            }
            let postTitleAttrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14)]
            let postTitleBold = NSMutableAttributedString(string:postTitle, attributes:postTitleAttrs)
            
            
            let pushMessageMiddle = pushNotification.isPostAuthor ? " replied to your post " : " replied to your saved post "
            let pushMessage = NSMutableAttributedString(string:fromUserName + pushMessageMiddle)
            pushMessage.appendAttributedString(postTitleBold)
            
            cell.contentLabel.attributedText = pushMessage
        }
        
        // Display post date when the post is more than one day ago, otherwise display relative date.
        cell.timeStampLabel.text = pushNotification.createdAt.timeAgo()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Show Post", sender: tableView.cellForRowAtIndexPath(indexPath))
        
        //Disable removing push notifications for now.
        /*
        let pushNotification = self.currentUser.pushNotificationsArray[indexPath.row]
        
        pushNotification.deleteInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                PushNotification.loadPushNotifications(self.currentUser) { (results, error) -> Void in
                    guard error == nil else { return }
                    
                    if (results.count > 0)
                    {
                        self.navigationController!.tabBarItem.badgeValue = String(results.count)
                    }
                    else
                    {
                        self.navigationController!.tabBarItem.badgeValue = nil
                    }
                    // Reload table data
                    self.tableView.reloadData()
                    
                }
            }
        }
       
    */
        
    }
    
    
}



