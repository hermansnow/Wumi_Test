//
//  Notification.swift
//  Wumi
//
//  Created by Guang Han on 5/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class PushNotification : AVObject, AVSubclassing  {
    
    
    // Extended properties
    @NSManaged var fromUser: User?
    @NSManaged var toUser: User?
    @NSManaged var post: Post?
    @NSManaged var isPostAuthor : Bool
   
    
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
    
    func sendPushForPost(containingVC: UIViewController)
    {
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success {
                Helper.PopupErrorAlert(containingVC, errorMessage: "\(error)")
            }
            else {
                // Create our Installation query
                let pushQuery = AVInstallation.query()
                pushQuery.whereKey("owner", equalTo: self.toUser);
                let pushMiddleMessage = self.isPostAuthor ? " replied to your post " : " replied to your saved post "
                
                let data: [NSObject : AnyObject] = [
                    "alert" : self.fromUser!.name! + pushMiddleMessage + self.post!.title!
                ]
                
                let push: AVPush = AVPush()
                //AVPush.setProductionMode(false)
                push.setQuery(pushQuery)
                push.setData(data)
                push.sendPushInBackground()
            }
        }
    }
    
    class func loadPushNotifications(user: User!, block: AVArrayResultBlock!) {
        
        // Load push notfications
        let query = PushNotification.query()
        
        // Sort results by
        query.orderByDescending("createdAt")
        
        query.includeKey("fromUser.name")
        query.includeKey("post.title")
        
        query.whereKey("toUser", equalTo: user)
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            guard let pushNotifications = results as? [PushNotification] else {
                return
            }
            
            user.pushNotificationsArray = pushNotifications
            block(results, error)
            
        }
    }


}
