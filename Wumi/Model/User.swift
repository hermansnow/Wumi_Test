//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Parse

class User: PFUser {
    
    //Extended properties for PFUser
    dynamic var graduationYear: Int = 0
    dynamic var displayName: String?
    
    // properties not for saving
    var confirmPassword: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
             self.registerSubclass() // Register the subclass
        }
    }
    
    override init() {
        super.init()
    }
    
    init(pfUser: PFUser?) {
        super.init()
        
        if let user = pfUser {
            self.objectId = user.objectId
            self.username = user.username
            self.password = user.password
            self.email = user.email
            self.graduationYear = user["graduationYear"] as! Int
            self.displayName = user["name"] as? String
        }
    }
    
    func addProfileInBackgroundWithBlock(block: PFBooleanResultBlock?) {
        // Save extended properties
        self.setObject(self.graduationYear, forKey: "graduationYear")
        self.setObject(self.displayName!, forKey: "name")
        self.saveInBackgroundWithBlock(block)
    }
    
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
    
    // Validate Username
    func validateUserName(inout error: String) -> Bool {
        if ((self.username?.utf16.count) <= 3) {
            error = "Length of user name should larger than 3 characters"
            return false
        }
        
        return true
    }
    
    // Validate User Password
    func validateUserPassword(inout error: String) -> Bool {
        if ((self.password?.utf16.count) <= 3) {
            error = "Length of user password should larger than 3 characters"
            return false
        }
        
        return true
    }
    
    // Validate Confirm Password
    func validateConfirmPassword(inout error: String) -> Bool {
        if (self.password != self.confirmPassword) {
            error = "Passwords entered not match"
            return false
        }
        
        return true
    }
    
}
