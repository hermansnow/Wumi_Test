//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Parse

class User: PFUser{
    
    //Extended properties for PFUser
    dynamic var gradYear: Int = 1900
    dynamic var name: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
             self.registerSubclass() // Register the subclass
        }
    }
    
    func validateUser() -> (valid: Bool, error: NSDictionary) {
        let errors = NSMutableDictionary()
        var errorMesage = ""
        var validUser = true
        
        // validate user name
        validUser = validateUserName(&errorMesage)
        if (!validUser) {
            errors.setValue(errorMesage, forKey: "NameError")
        }
        
        // validate user password
        validUser = validateUserPassword(&errorMesage)
        if (!validUser) {
            errors.setValue(errorMesage, forKey: "PasswordError")
        }
        
        return (validUser, errors)

    }
    
    // Validate User Name
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
    
}
