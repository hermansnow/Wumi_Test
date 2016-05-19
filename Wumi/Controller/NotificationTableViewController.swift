//
//  NotificationTableViewController.swift
//  Wumi
//
//  Created by Guang Han on 4/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
    
    var currentUser = User.currentUser()
    lazy var pushNotifications = [PushNotification]() // array for push notifications
    var updatedAtDateFormatter = NSDateFormatter()

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.navigationController!.tabBarItem = UITabBarItem(title: "Notifications", image: nil,  tag: 1)
        
        PushNotification().loadPushNotifications(currentUser){ (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            self.navigationController!.tabBarItem.badgeValue = String(results.count)
        }

        
}
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
        // Initialize tableview
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = .SingleLine
        self.tableView.backgroundColor = Constants.General.Color.BackgroundColor
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

         self.currentUser.pushNotificationsArray.removeAll()
         self.updatedAtDateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
         self.navigationController!.tabBarItem.badgeValue = nil
        
        // Load data
        PushNotification().loadPushNotifications(self.currentUser) { (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
             self.navigationController!.tabBarItem.badgeValue = String(results.count)
            // Reload table data
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postVC = segue.destinationViewController as? PostViewController where segue.identifier == "Show Post" {
            
            guard let cell = sender as? UITableViewCell else { return }
            guard let indexPath = tableView.indexPathForCell(cell) else { return }
            let pushNotification = User.currentUser().pushNotificationsArray[indexPath.row]
            let post = Post.query().getObjectWithId(pushNotification.post!.objectId) as? Post
            postVC.post = post
                       
            }
    }
    
        // MARK: TableView delegate & data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentUser.pushNotificationsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.numberOfLines = 0
       
        let pushNotification = self.currentUser.pushNotificationsArray[indexPath.row]
       
        User.query().getObjectInBackgroundWithId(pushNotification.fromUser!.objectId){ (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            let fromUserName = user.name!
            Post.query().getObjectInBackgroundWithId(pushNotification.post!.objectId){
                (result, error) -> Void in
                guard let post = result as? Post where error == nil else { return }
                
                let postTitle  = post.title!
                let postTitleAttrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14)]
                let postTitleBold = NSMutableAttributedString(string:postTitle, attributes:postTitleAttrs)
                
                
                let pushMessageMiddle = pushNotification.isPostAuthor ? " replied to your post " : " replied to your saved post "
                let pushMessage = NSMutableAttributedString(string:fromUserName + pushMessageMiddle)
                pushMessage.appendAttributedString(postTitleBold)
                
                cell.contentLabel.attributedText = pushMessage;
                
            }
        }
        cell.timeStampLabel.text = self.updatedAtDateFormatter.stringFromDate(pushNotification.createdAt)
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Show Post", sender: tableView.cellForRowAtIndexPath(indexPath))
        
        let pushNotification = self.currentUser.pushNotificationsArray[indexPath.row]
        
        pushNotification.deleteInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(self, errorMessage: "\(error)")
            }
            else {
                PushNotification().loadPushNotifications(self.currentUser) { (results, error) -> Void in
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
       
        
        
    }
    
    
}



