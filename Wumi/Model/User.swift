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
    @NSManaged var avatarImageFile: AVFile?
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var pinyin: String?
    @NSManaged weak var contact: Contact?
    @NSManaged var favoriteUsers: AVRelation?
    
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
    
    // MARK: Property functions
    
    func addFavoriteUser(favoriteUser: User!) {
        // Do not allow favorite yourself
        if self == favoriteUser { return }
        
        favoriteUsers!.addObject(favoriteUser)
        
        saveInBackground()
    }
    
    func removeFavoriteUser(user: User!) {
        // Do not allow favorite yourself
        if self == user { return }
        
        favoriteUsers!.removeObject(user    )
        
        saveInBackground()
    }
    
    func isFavoriteUser(user: User!, block: AVIntegerResultBlock!) {
        let query = favoriteUsers!.query()
        
        query.whereKey("objectId", equalTo: user.objectId)
        
        query.countObjectsInBackgroundWithBlock(block)
    }
    
    // MARK: Validation functions
    
    // Validate user information
    func validateUser(block: (valid: Bool, error: NSDictionary) -> Void) {
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
    
    // MARK: Avatar functions
    
    // Load avatar. This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background
    func loadAvatar(size: CGSize, block: AVImageResultBlock!) {
        if avatarImageFile == nil {
            if block != nil {
                block!(nil, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            return
        }
        
        avatarImageFile?.getThumbnail(true, width: Int32(size.width), height: Int32(size.height), withBlock: block)
    }
    
    // Save avatar to cloud server
    func saveAvatarFile(avatarImage: UIImage?, block: (success: Bool, error: NSError?) -> Void) {
        if avatarImage == nil {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        if let imageData = scaleImage(avatarImage!, ToSize: 500) {
            avatarImageFile = AVFile(name: "avatar.jpeg", data: imageData)
            avatarImageFile!.saveInBackgroundWithBlock(block)
        }
    }
    
    // Compress image in JPEG format. The max size of image save in Parse server is 10.0MB
    func scaleImage(image: UIImage, ToSize size: Int) -> NSData? {
        var compress:CGFloat = 1.0
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
    
    // MARK: Queries
    class func loadUsers(skip: Int, limit: Int, WithName name: String = "", block: AVArrayResultBlock!) {
        let query = User.query()
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 24 * 3600
        
        query.skip = skip
        query.limit = limit
        
        if !name.isEmpty {
            // In terms of Chinese input, search name only
            if name.containChinese() {
                query.whereKey("name", containsString: name)
                // Sort results by name
                query.orderByAscending("name")
            }
            else {
                // In terms of English input, search name and pinyin
                query.whereKey("pinyin", containsString: name)
                // Sort results by name search index, then by original name
                query.orderByAscending("pinyin")
                query.addAscendingOrder("name")
            }
        }
        else {
            query.orderByAscending("pinyin")
        }
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
}
