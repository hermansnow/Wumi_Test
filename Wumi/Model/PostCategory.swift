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
    
    /**
     Load post category from server asynchronously.
     
     - Parameters:
        - block: closure includes an array of post categories sorted alphabatically or a wumi error if failed.
     */
    class func loadCategories(block: ([PostCategory], WumiError?) -> Void) {
        let query = PostCategory.query()
        
        query.cachePolicy = .CacheElseNetwork
        query.maxCacheAge = 3600 * 24 * 2 // 2 days
        
        query.orderByAscending("name")
        
        query.findObjectsInBackgroundWithBlock { (results, error) in
            guard let postCategories = results as? [PostCategory] else {
                block([], WumiError(type: .Query, error: "Failed to get post category list."))
                return
            }
            
            block(postCategories, ErrorHandler.parseError(error))
        }
    }
    
}

// MARK: Equatable
func ==(lhs: PostCategory, rhs: PostCategory) -> Bool {
    return lhs.name == rhs.name
}
