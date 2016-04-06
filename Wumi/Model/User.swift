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
    @NSManaged var emailPublic: Bool
    @NSManaged var phoneNumber: String?
    @NSManaged var phonePublic: Bool
    @NSManaged var avatarImageFile: AVFile?
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var pinyin: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var favoriteUsers: AVRelation?
    @NSManaged var professions: [Profession]
    @NSManaged var savedPosts: AVRelation?
    
    // Properties should not be saved into PFUser
    var confirmPassword: String?
    var favoriteUsersArray: [User] = []
    var savedPostsArray: [Post] = []
    
    var location: Location {
        get {
            return Location(Country: self.country, City: self.city)
        }
        set {
            self.country = newValue.country
            self.city = newValue.city
        }
        
    }
    
    // Use objectId as hashValue
    override var hashValue: Int {
        get {
            return self.objectId.hashValue
        }
    }
    
    enum UserSearchType {
        case All, Favorites, Graduation
    }
    
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
        error = ""
        if ((self.username?.utf16.count) <= 3) {
            error = "Length of user name should larger than 3 characters"
            return false
        }
        return true
    }
    
    // Validate password
    func validateUserPassword(inout error: String) -> Bool {
        error = ""
        if ((self.password?.utf16.count) <= 3) {
            error = "Length of user password should larger than 3 characters"
            return false
        }
        return true
    }
    
    // Validate comfirm password
    func validateConfirmPassword(inout error: String) -> Bool {
        error = ""
        if (self.password != self.confirmPassword) {
            error = "Passwords entered not match"
            return false
        }
        return true
    }
    
    // MARK: Avatar functions
    
    // Load avatar. This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background
    func loadAvatar(ScaleToSize size: CGSize? = nil, WithBlock block: AVImageResultBlock!) {
        guard let file = avatarImageFile else {
            block!(nil, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            // create a queue to parse image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                var image: UIImage?
                
                if let imageData = data where error == nil, let originalImage = UIImage(data: imageData) {
                    if size != nil {
                        image = originalImage.scaleToSize(size!)
                    }
                    else {
                        image = originalImage
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    block(image, error)
                })
            })
        }
    }
    
    // Save avatar to cloud server
    func saveAvatarFile(avatarImage: UIImage?, block: (success: Bool, error: NSError?) -> Void) {
        guard let image = avatarImage else {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Image is nil"]))
            return
        }
        
        // Scale image
        guard let imageData = image.compressToSize(500) else {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Cannot scale image"]))
            return
        }
        
        self.avatarImageFile = AVFile(name: "avatar.jpeg", data: imageData)
        self.avatarImageFile!.saveInBackgroundWithBlock(block)
    }
    
    // MARK: User queries
    
    // Fetch a user based on objectID
    class func fetchUser(objectId id: String, block: AVObjectResultBlock!) {
        let query = User.query()
        query.cachePolicy = .NetworkElseCache
        query.includeKey("professions")
        query.getObjectInBackgroundWithId(id, block: block)
    }
    
    func loadUsers(limit limit: Int = 200, type: UserSearchType = .All, searchString: String = "", sinceUser: User? = nil, block: AVArrayResultBlock!) {
        guard let query = self.getQueryFromSearchType(type) else {
            block([], NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Failed in starting query"]))
            return
        }
        
        // Parse index
        let index: String
        if searchString.containChinese() {
            index = "name" // In terms of Chinese input, directly search name
        }
        else {
            index = "pinyin" // In terms of English input, search pinyin
        }
        
        // Handle load more
        let finalQuery: AVQuery
        if let user = sinceUser, equalQuery = self.getQueryFromSearchType(type) {
            query.whereKey(index, greaterThan: user[index])
            equalQuery.whereKey(index, equalTo: user[index])
            equalQuery.whereKey("objectId", greaterThan: user.objectId)
            finalQuery = AVQuery.orQueryWithSubqueries([query, equalQuery])
        }
        else {
            finalQuery = query
        }
        
        // Add filter based on search type
        if type == .Graduation {
            finalQuery.whereKey("graduationYear", equalTo: self.graduationYear)
        }
        
        // Handler search string
        if !searchString.isEmpty {
            finalQuery.whereKey(index, containsString: searchString)
        }
        
        // Sort results by
        finalQuery.orderByAscending(index)
        finalQuery.addAscendingOrder("objectId")
        
        finalQuery.limit = limit
        
        // Cache policy
        finalQuery.cachePolicy = .NetworkElseCache
        finalQuery.maxCacheAge = 24 * 3600
        
        finalQuery.findObjectsInBackgroundWithBlock(block)
    }
    
    // Get associated AVQuery object based on search type
    func getQueryFromSearchType(type: UserSearchType) -> AVQuery? {
        let query: AVQuery?
        
        switch (type) {
        case .All:
            query = User.query()
        case .Favorites:
            query = self.favoriteUsers?.query()
        case .Graduation:
            query = User.query()
        }
        
        return query
    }
    
    // MARK: Favorite user queries
    
    func addFavoriteUser(user: User!, block: AVBooleanResultBlock?) {
        // Can not favorite yourself
        guard let favoriteUsers = self.favoriteUsers where user != self else {
            if block != nil {
                return block!(false, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            else {
                return
            }
        }
        
        favoriteUsers.addObject(user)
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            defer {
                if block != nil {
                    block!(success, error)
                }
            }
            
            guard success && error == nil else { return }
            
            self.favoriteUsersArray.appendUniqueObject(user)
        }
    }
    
    func removeFavoriteUser(user: User!, block: AVBooleanResultBlock?) {
        guard let favoriteUsers = self.favoriteUsers else {
            if block != nil {
                return block!(false, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            else {
                return
            }
        }
        
        favoriteUsers.removeObject(user)
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            defer {
                if block != nil {
                    block!(success, error)
                }
            }
            
            guard success && error == nil else { return }
            
            self.favoriteUsersArray.removeObject(user)
        }
    }
    
    func hasFavoriteUser(user: User!, block: AVIntegerResultBlock!) {
        let query = favoriteUsers!.query()
        
        query.whereKey("objectId", equalTo: user.objectId)
        
        query.countObjectsInBackgroundWithBlock(block)
    }
    
    func loadFavoriteUsers(block: AVArrayResultBlock!) {
        guard let favoriteUsers = self.favoriteUsers else {
            self.favoriteUsersArray.removeAll()
            block([], NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        // Load favorite users for user
        favoriteUsers.query().findObjectsInBackgroundWithBlock { (results, error) -> Void in
            self.favoriteUsersArray = results as! [User]
            block(results, error)
        }
    }
    
    // MARK: Profession queries
    
    func updateProfessions(newProfessions: [Profession]) {
        professions.removeAll()
        professions.appendContentsOf(newProfessions)
        
        saveInBackground()
    }
    
    // MARK: Saved post queries
    
    func savePost(post: Post!, block: AVBooleanResultBlock?) {
        guard let savedPosts = self.savedPosts else {
            if block != nil {
                return block!(false, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            else {
                return
            }
        }
        
        savedPosts.addObject(post)
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            defer {
                if block != nil {
                    block!(success, error)
                }
            }
            
            guard success && error == nil else { return }
            
            self.savedPostsArray.appendUniqueObject(post)
        }
    }
    
    func unsavePost(post: Post!, block: AVBooleanResultBlock?) {
        guard let savedPosts = self.savedPosts else {
            if block != nil {
                return block!(false, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            else {
                return
            }
        }
        
        savedPosts.removeObject(post)
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            defer {
                if block != nil {
                    block!(success, error)
                }
            }
            
            guard success && error == nil else { return }
            
            self.savedPostsArray.removeObject(post)
        }
    }
    
    func loadSavedPosts(block: AVArrayResultBlock!) {
        guard let savedPosts = self.savedPosts else {
            self.savedPostsArray.removeAll()
            block([], NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        // Load saved posts for user
        savedPosts.query().findObjectsInBackgroundWithBlock { (results, error) -> Void in
            self.savedPostsArray = results as! [Post]
            block(results, error)
        }
    }
}

// MARK: Equatable
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.objectId == rhs.objectId
}
