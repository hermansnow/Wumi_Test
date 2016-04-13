//
//  Comment.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class Comment: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var author: User?
    @NSManaged var content: String?
    @NSManaged var post: Post!
    @NSManaged var reply: Comment?
    
    // MARK: Initializer and subclassing functions
    
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
        return "Comment"
    }
    
    class func loadRepliesForPost(post: Post, skip: Int = 0, limit: Int = 200, block: AVArrayResultBlock!) {
        let query = Comment.query()
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 2
        
        query.skip = skip
        query.limit = limit
        query.whereKey("post", equalTo: post)
        query.includeKey("reply.author")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
    class func sendNewCommentForPost(post: Post, author: User, content: String?, replyComment: Comment?,block: AVBooleanResultBlock!) {
        let comment = Comment()
        comment.author = author
        comment.post = post
        comment.content = content
        comment.reply = replyComment
        
        comment.saveInBackgroundWithBlock { (success, error) -> Void in
            guard success && error == nil else {
                block(success, error)
                return
            }
            
            post.fetchWhenSave = true
            post.incrementKey("commentCount")
            post.saveInBackgroundWithBlock(block)
        }
    }
}