//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Parse
import UIKit

class User: PFUser {
    
    // Extended properties
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var profileImageFile: PFFile?
    
    // Properties should not be saved into PFUser
    var confirmPassword: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
             self.registerSubclass() // Register the subclass
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // Convenience initializer from a PFUser instance
    convenience init(pfUser: PFUser) {
        self.init()
        self.username = pfUser.username
        self.password = pfUser.password
        self.email = pfUser.email
        if let graduationYear = pfUser.objectForKey("graduationYear") as? Int {
            self.graduationYear = graduationYear
        }
        if let name = pfUser.objectForKey("name") as? String {
            self.name = name
        }
        if let profileImageFile = pfUser.objectForKey("profileImageFile") as? PFFile {
            self.profileImageFile = profileImageFile
            loadProfileImageWithBlock(nil) // Load the profile image into local cache in background thread
        }
    }
    
    // Get current login User instance
    override class func currentUser() -> User? {
        var user: User?
        
        if let pfUser = super.currentUser() {
            if pfUser.objectId != nil {
                user = User(pfUser: pfUser)
            }
        }
        return user
    }
    
    func editInBackgroundWithBlock(block: PFBooleanResultBlock?) {
        // Save extended properties
        //self.setObject(self.graduationYear, forKey: "graduationYear")
        //self.setObject(self.displayName!, forKey: "name")
        self.saveInBackgroundWithBlock(block)
    }
    
    func loadProfileImageWithBlock(block: PFDataResultBlock?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var imageData: NSData?
            var loadError: NSError?
            if self.profileImageFile == nil {
                loadError = NSError(domain: "wumi.com", code: 1, userInfo: nil)
                return
            }
            
            if ((self.profileImageFile?.isDataAvailable) != nil) {
                do {
                    imageData = try self.profileImageFile?.getData()
                } catch {
                    loadError = NSError(domain: "wumi.com", code: 2, userInfo: nil)
                }
            }
            else {
                self.profileImageFile?.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    imageData = data
                    loadError = error
                })
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if block != nil {
                    block!(imageData, loadError)
                }
            }
        }
    }
    
    func saveProfileImageFile(profileImage: UIImage?, WithBlock block: (success: Bool, error: NSError?) -> Void) {
        if profileImage == nil {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        if let imageData = scaleImage(profileImage!, ToSize: 1048576) {
            profileImageFile = PFFile(data: imageData)
            profileImageFile!.saveInBackgroundWithBlock(block)
        }
    }
    
    func scaleImage(image: UIImage, ToSize size: Int) -> NSData? {
        var compress:CGFloat = 1.0;
        var imageData:NSData?
        
        if let jpegData = UIImageJPEGRepresentation(image, compress) {
            compress = CGFloat(size) / CGFloat(jpegData.length)
            if compress < 1.0 {
                imageData = UIImageJPEGRepresentation(image, compress);
            }
            else {
                imageData = jpegData
            }
        }
        return imageData;
    }

    // MARK: Validation Functions
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
