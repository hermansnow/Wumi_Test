//
//  Post.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class Post: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var author: User?
    @NSManaged var title: String?
    @NSManaged var content: String?
    @NSManaged var commentCount: Int
    @NSManaged var categories: [PostCategory]
    
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
        return "Post"
    }
    
    enum PostSearchType {
        case All
        case Category
    }
    
    // MARK: Queries
    class func loadPosts(limit limit: Int = 200, cutoffTime: NSDate? = nil,  block: AVArrayResultBlock!) {
        let query = Post.query()
        let index = "updatedAt" // Sort based on last update time
        
        if let cutoffTime = cutoffTime {
            query.whereKey(index, lessThan: cutoffTime)
        }
        query.orderByDescending(index)
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 24 * 3600
        
        query.limit = limit
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
    class func sendNewPost(author author: User, title: String?, content: String?, categories: [PostCategory] = [PostCategory](), block: AVBooleanResultBlock!) {
        let post = Post()
        post.author = author
        post.title = title ?? "No Title"
        post.content = content
        post.categories = categories
        post.commentCount = 0
        
        post.saveInBackgroundWithBlock(block)
    }
}
