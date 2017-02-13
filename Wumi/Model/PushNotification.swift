//
//  Notification.swift
//  Wumi
//
//  Created by Guang Han on 5/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class PushNotification : AVObject, AVSubclassing  {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var fromUser: User?
    @NSManaged var toUser: User?
    @NSManaged var post: Post?
    @NSManaged var isPostAuthor : Bool
    
    // MARK: Initializer
    
    // Must have this init for subclassing AVObject
    override init() {
        super.init()
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass() // Register the subclass
        }
    }
    
    // Must have this class function for subclassing AVObject
    class func parseClassName() -> String? {
        return "PushNotification"
    }
    
    init(fromUser: User, toUser: User, post: Post, isPostAuthor: Bool) {
        
        super.init();
        self.fromUser = fromUser
        self.toUser = toUser
        self.post = post
        self.isPostAuthor = isPostAuthor
    }
    
    // MARK: Queries
    
    /**
     Save this notification record on server and push a remote notification if success.
     */
    func sendPushForPost() {
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            guard success && error == nil else {
                ErrorHandler.log(error.localizedDescription)
                return
            }
            
            // Create our Installation query
            let pushQuery = AVInstallation.query()
            pushQuery.whereKey("owner", equalTo: self.toUser);
            let pushMiddleMessage = self.isPostAuthor ? " replied to your post " : " replied to your saved post "
                
            let data: [NSObject : AnyObject] = [
                "alert" : self.fromUser!.name! + pushMiddleMessage + self.post!.title!
            ]
                
            let push: AVPush = AVPush()
            push.setQuery(pushQuery)
            push.setData(data)
            push.sendPushInBackground()
        }
    }
    
    /**
     Load all new push notifications for a specific user from server asynchronously.
     
     - Parameters:
        - user: The target user of push notifications.
        - block: Completion handler returns an array of new push notifications or a wumi error if failed.
     */
    class func loadPushNotifications(user: User, block: (results: [PushNotification]?, error: WumiError?) -> Void) {
        let query = PushNotification.query()
        
        // Sort results by
        query.orderByDescending("createdAt")
        
        query.includeKey("fromUser.name")
        query.includeKey("post.title")
        
        query.whereKey("toUser", equalTo: user)
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            guard let pushNotifications = results as? [PushNotification] where error == nil else {
                block(results: nil, error: ErrorHandler.parseError(error))
                return
            }
            
            block(results: pushNotifications, error: nil)
        }
    }
    
    /**
     Check whether has new push notification for a specific user or not.
     
     - Parameters:
        - user: The target user of push notifications.
        - block: Completion handler returns number of new push notification or a wumi error if failed.
     */
    class func hasNewPushNotification(user: User, block: (count: Int, error: WumiError?) -> Void) {
        let query = PushNotification.query()
        
        query.whereKey("toUser", equalTo: user)
        
        // Set cache policy
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.countObjectsInBackgroundWithBlock { (count, error) in
            block(count: count, error: ErrorHandler.parseError(error))
        }
    }
}
