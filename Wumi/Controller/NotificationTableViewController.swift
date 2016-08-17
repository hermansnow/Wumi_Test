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

class NotificationTableViewController: UITableViewController {
    
    var currentUser = User.currentUser()
    lazy var pushNotifications = [PushNotification]() // array for push notifications
    var updatedAtDateFormatter = NSDateFormatter()

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.navigationController!.tabBarItem = UITabBarItem(title: "Notification", image: Constants.Notification.Image.TabBarIcon,  tag: 1)
        
        PushNotification.loadPushNotifications(currentUser){ (results, error) -> Void in
            guard results.count > 0 && error == nil else { return }
            
            if let navigationController = self.navigationController {
                navigationController.tabBarItem.badgeValue = String(results.count)
            }
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
        self.tableView.separatorColor = UIColor.init(hexString: "#D5D5D5")
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

         self.currentUser.pushNotificationsArray.removeAll()
        self.updatedAtDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
         self.navigationController!.tabBarItem.badgeValue = nil
        
        // Load data
        PushNotification.loadPushNotifications(self.currentUser) { (results, error) -> Void in
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
        let intervalSinceNow = pushNotification.createdAt.timeIntervalSinceNow
        // Display post date when the post is more than one day ago, otherwise display relative date.
        if (intervalSinceNow < -24*60*60)
        {
            cell.timeStampLabel.text = self.updatedAtDateFormatter.stringFromDate(pushNotification.createdAt)
        }
        else
        {
            cell.timeStampLabel.text = FormatterKit.TTTTimeIntervalFormatter().stringForTimeInterval(intervalSinceNow)
        }
        
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



