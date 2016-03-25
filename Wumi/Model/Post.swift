//
//  Post.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class Post: AVObject {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var author: User?
    @NSManaged var title: String?
    @NSManaged var content: String?
    
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
    
    class func sendNewPost(author author: User, title: String? = "No Title", content: String?, block: AVBooleanResultBlock!) {
        let post = Post()
        post.author = author
        post.title = title
        post.content = content
        
        post.saveInBackgroundWithBlock(block)
    }
}
