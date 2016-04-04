//
//  PostCategory.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostCategory: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var name: String?
    
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
        return "PostCategory"
    }
    
    // MARK: Query
    class func loadCategories(block: AVArrayResultBlock!) {
        let query = PostCategory.query()
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 24 * 3600
        
        query.orderByAscending("name")
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
}

// MARK: Equatable
func ==(lhs: PostCategory, rhs: PostCategory) -> Bool {
    return lhs.name == rhs.name
}