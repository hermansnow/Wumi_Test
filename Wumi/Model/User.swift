//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import AVOSCloud
import UIKit

class User: AVUser {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var contact: Contact
    
    // Properties should not be saved into PFUser
    var confirmPassword: String?
    
    // MARK: Initializer
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
             self.registerSubclass() // Register the subclass
        }
    }
    
    // MARK: Validation functions
    
    // Validate user information
    func validateUserWithBlock(block: (valid: Bool, error: NSDictionary) -> Void) {
        let errors = NSMutableDictionary()
        var errorMesage = ""
        
        // validate user name
        if (!validateUserName(&errorMesage)) {
            errors.setValue(errorMesage, forKey: "NameError")
        }
        
        // Validate user password
        if (!validateUserPassword(&errorMesage)) {
            errors.setValue(errorMesage, forKey: "PasswordError")
        }
        
        // Validate confirm password
        if (!validateConfirmPassword(&errorMesage)) {
            errors.setValue(errorMesage, forKey: "ConfirmPasswordError")
        }
        
        block(valid: errors.count == 0, error: errors)
    }
    
    // Validate username
    func validateUserName(inout error: String) -> Bool {
        if ((self.username?.utf16.count) <= 3) {
            error = "Length of user name should larger than 3 characters"
            return false
        }
        return true
    }
    
    // Validate password
    func validateUserPassword(inout error: String) -> Bool {
        if ((self.password?.utf16.count) <= 3) {
            error = "Length of user password should larger than 3 characters"
            return false
        }
        return true
    }
    
    // Validate comfirm password
    func validateConfirmPassword(inout error: String) -> Bool {
        if (self.password != self.confirmPassword) {
            error = "Passwords entered not match"
            return false
        }
        return true
    }
    
}
