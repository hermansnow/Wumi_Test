//
//  Contact.swift
//  Wumi
//
//  Created by Herman on 2/5/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import AVOSCloud

class Contact: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var city: String?
    @NSManaged var country: String?
    
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
        return "Contact"
    }
    
    func location() -> String {
        return "\(Location(Country: country, City: city))"
    }
}
