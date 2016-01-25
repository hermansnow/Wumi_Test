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
    var profileImage: UIImage?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
             self.registerSubclass() // Register the subclass
        }
    }
    
    // Return a User instance from a PFUser instance
    class func copyFromPFUser(pfUser: PFUser?) -> User? {
        var user: User?
        
        if let currentPFUser = pfUser {
            user = User.objectWithoutDataWithObjectId(currentPFUser.objectId)
            user!.username = currentPFUser.username
            user!.password = currentPFUser.password
            user!.email = currentPFUser.email
            if let graduationYear = currentPFUser.objectForKey("graduationYear") as? Int {
                user!.graduationYear = graduationYear
            }
            if let name = currentPFUser.objectForKey("name") as? String {
                user!.name = name
            }
            if let profileImageFile = currentPFUser.objectForKey("profileImage") as? PFFile {
                user!.profileImageFile = profileImageFile
            }
        }
        return user
    }
    
    // Get current login User instance
    override class func currentUser() -> User? {
        var user: User?
        
        if let pfUser = super.currentUser() {
            if pfUser.objectId != nil {
                user = User.copyFromPFUser(pfUser)
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
    
    func loadProfileImageWithBlock(block: (valid: Bool, error: NSError?) -> Void) {
        if profileImageFile == nil {
            block(valid: false, error: NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        profileImageFile!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.profileImage = UIImage(data: imageData)
                }
                block(valid: true, error: nil)
            }
            else {
                block(valid: false, error: error)
            }
        }
    }
    
    func saveProfileImageFileWithBlock(block: (valid: Bool, error: NSError?) -> Void) {
        if profileImage == nil {
            block(valid: false, error: NSError(domain: "wumi.com", code: 1, userInfo: nil))
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
