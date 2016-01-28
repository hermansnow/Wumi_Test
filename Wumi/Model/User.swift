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
    // MARK: Properties
    
    // Extended properties
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var profileImageFile: PFFile?
    
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
    
    // MARK: Image functions
    
    // Load profile image. This function will check whether the image in in local cache first. If not, then try download it from Parse server asynchronously in background
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
    
    // Save profile image to Parse file server
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
    
    // Compress image in JPEG format. The max size of image save in Parse server is 10.0MB
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
