//
//  Profession.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class Profession: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var name: String?
    @NSManaged var category: String?
    
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
        return "Profession"
    }
    
    // Compare function
    func compareTo(target: Profession) -> Bool {
        return name == target.name && category == target.category
    }
    
    // MARK: Query
    class func loadAllProfessions(block: AVArrayResultBlock!) {
        let query = Profession.query()
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 24 * 3600
        
        query.orderByAscending("category")
        query.addAscendingOrder("name")
        
        query.findObjectsInBackgroundWithBlock(block)
    }

}

