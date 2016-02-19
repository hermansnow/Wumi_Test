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
    @NSManaged weak var user: User!
    @NSManaged var city: String?
    @NSManaged var country: String?
    
    // MARK: Initializer and subclassing functions
    
    // Must have this init for subclassing AVObject
    private override init() {
        super.init();
    }
    
    init(user: User) {
        super.init();
        self.user = user;
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
    
    // Database query functions
    class func createContactForUser(user: User, WithBlock block: AVBooleanResultBlock?) -> Void {
        getContactForUser(user) { (result, error) -> Void in
            if error != nil {
                print("Error when creating contact for user " + "\(user)" + ": " + "\(error)")
                return
            }
            if result != nil {
                print("Contact for user: " + "\(user)" + "exists.")
                return
            }
            
            let contact = Contact(user: user)
            if block != nil {
                contact.saveInBackgroundWithBlock(block)
            }
            else {
                contact.saveInBackground()
            }
        }
    }
    
    class func getContactForUser(user: User, WithBlock block: AVObjectResultBlock!) {
        let query = Contact.query()
        query.whereKey("user", equalTo: user)
        
        query.getFirstObjectInBackgroundWithBlock(block)
    }
}
