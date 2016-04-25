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
    
    // MARK: Queries
    class func loadPosts(limit limit: Int = 10, type: PostSearchType = .All, cutoffTime: NSDate? = nil, searchString: String = "", user: User? = nil, block: AVArrayResultBlock!) {
        guard var query = Post.getQueryFromSearchType(type, forUser: user) else {
            block([], NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Failed in starting query"]))
            return
        }
        
        // Handler search string
        if let titleQuery = Post.getQueryFromSearchType(type, forUser: user), contentQuery = Post.getQueryFromSearchType(type, forUser: user) where !searchString.isEmpty {
            titleQuery.whereKey("title", matchesRegex: searchString, modifiers: "im")
            contentQuery.whereKey("content", matchesRegex: searchString, modifiers: "im")
            query = AVQuery.orQueryWithSubqueries([titleQuery, contentQuery])
        }
        
        let index = "updatedAt" // Sort based on last update time
        
        // Load posts earlier than a cut-off timestamp
        if let cutoffTime = cutoffTime {
            query.whereKey(index, lessThan: cutoffTime)
        }
        
        query.orderByDescending(index)
        
        query.limit = limit
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24
        
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
    
    // Get associated AVQuery object based on search type
    class func getQueryFromSearchType(searchType: PostSearchType, forUser user: User? = nil) -> AVQuery? {
        var query: AVQuery? = nil
        
        switch (searchType) {
        case .All:
            query = Post.query()
        case .Saved:
            guard let searchUser = user else { break }
            
            query = searchUser.savedPosts!.query()
        }
        
        return query
    }
}

// MARK: Equatable

func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.objectId == rhs.objectId
}

// MARK: Post Search Type enum

enum PostSearchType {
    case All
    case Saved
}
