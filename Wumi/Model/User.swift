//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import AVOSCloud
import UIKit
import CoreData

class User: AVUser, NSCoding, TimeBaseCacheable {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var emailPublic: Bool
    @NSManaged var phoneNumber: String?
    @NSManaged var phonePublic: Bool
    @NSManaged var avatarImageFile: AVFile?
    @NSManaged var avatarThumbnail: AVFile?
    @NSManaged var graduationYear: Int
    @NSManaged var name: String?
    @NSManaged var pinyin: String?
    @NSManaged var city: String?
    @NSManaged var state: String?
    @NSManaged var country: String?
    @NSManaged var favoriteUsers: AVRelation?
    @NSManaged var professions: [Profession]
    @NSManaged var savedPosts: AVRelation?
    
    // Properties should not be saved into PFUser
    var confirmPassword: String?
    lazy var favoriteUsersArray: [User] = []
    lazy var savedPostsArray: [Post] = []
    var maxCacheAge: NSTimeInterval? = 3600 * 48
    var expireAt: NSDate? = nil
    
    var location: Location {
        get {
            return Location(Country: self.country, State: self.state, City: self.city)
        }
        set {
            self.country = newValue.country
            self.state = newValue.state
            self.city = newValue.city
        }
        
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
    
    override init!(className newClassName: String!) {
        super.init(className: newClassName)
    }
    
    override init() {
        super.init()
    }
    
    // initilizer for NSCoding
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if let objectId = aDecoder.decodeObjectForKey("objectId") as? String {
            self.objectId = objectId
        }
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let objectId = self.objectId {
            aCoder.encodeObject(objectId, forKey: "objectId")
        }
        if let name = self.name {
            aCoder.encodeObject(name, forKey: "name")
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
    func loadAvatar(ScaleToSize size: CGSize? = nil, block: AVImageResultBlock!) {
        guard let file = self.avatarImageFile else {
            block!(nil, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        AVFile.loadImageFile(file, size: size, block: block)
    }
    
    func loadAvatarThumbnail(ScaleToSize size: CGSize? = nil, block: AVImageResultBlock!) {
        guard let file = self.avatarThumbnail else {
            block!(nil, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        AVFile.loadImageFile(file, size: size, block: block)
    }
    
    // Save avatar to cloud server
    func saveAvatarFile(avatarImage: UIImage?, block: (success: Bool, error: NSError?) -> Void) {
        guard let image = avatarImage else {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Image is nil"]))
            return
        }
        
        AVFile.saveImageFile(&self.avatarThumbnail, image: image, size: CGSize(width: Constants.General.Size.AvatarThumbnail.Width, height: Constants.General.Size.AvatarThumbnail.Height), block: block)
        AVFile.saveImageFile(&self.avatarImageFile, image: image, block: block)
    }
    
    // MARK: User queries
    func loadUsers(limit limit: Int = 200, type: UserSearchType = .All, searchString: String = "", sinceUser: User? = nil, block: AVArrayResultBlock!) {
        guard var query = User.getQueryFromSearchType(type, forUser: self) else {
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
        if let user = sinceUser, indexQuery = User.getQueryFromSearchType(type, forUser: self), tieBreakerQuery = User.getQueryFromSearchType(type, forUser: self) {
            indexQuery.whereKey(index, greaterThan: user[index])
            tieBreakerQuery.whereKey(index, equalTo: user[index])
            tieBreakerQuery.whereKey("objectId", greaterThan: user.objectId)
            query = AVQuery.orQueryWithSubqueries([indexQuery, tieBreakerQuery])
        }
        
        // Add filter based on search type
        if type == .Graduation {
            query.whereKey("graduationYear", equalTo: self.graduationYear)
        }
        
        // Handler search string
        if !searchString.isEmpty {
            query.whereKey(index, containsString: searchString)
        }
        
        // Sort results by
        query.orderByAscending(index)
        query.addAscendingOrder("objectId")
        
        query.limit = limit
        
        // Cache policy
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock { (results, error) in
            if let users = results as? [User] where error == nil {
                for user in users {
                    User.cacheUserData(user)
                }
            }
            block(results, error)
        }
    }
    
    // Fetch an user based on object ID
    class func fetchUserInBackground(objectId id: String, block: AVObjectResultBlock!) {
        let query = User.query()
        query.includeKey("professions")
        
        query.cachePolicy = .CacheThenNetwork
        query.maxCacheAge = 3600 * 24 * 30
        
        query.getObjectInBackgroundWithId(id) { (result, error) in
            if let user = result as? User where error == nil {
                User.cacheUserData(user)
            }
            
            block(result, error)
        }
    }
    
    override func fetchIfNeededInBackgroundWithBlock(block: AVObjectResultBlock!) {
        if self.isDataAvailable() {
            block(self, nil)
            return
        }
        
        // Try fetch data from memory by objectId
        if let user = DataManager.sharedDataManager.cache["user_" + self.objectId] as? User {
            print("Found \(user.name) in memory cache")
            block(user, nil)
            return
        }
        
        // Try fetch data from
        User.fetchUserInBackground(objectId: self.objectId, block: block)
    }

    public class func cacheUserData(user: User) {
        //BackupUser.saveUser(user)
        
        // Save into local cache
        user.maxCacheAge = 3600 * 24
        DataManager.sharedDataManager.cache["user_" + user.objectId] = user
        
        print("Cached \(user.name) in memory")
    }
    
    // Get associated AVQuery object based on search type
    class func getQueryFromSearchType(searchType: UserSearchType, forUser user: User? = nil) -> AVQuery? {
        var query: AVQuery? = nil
        
        switch (searchType) {
        case .All:
            query = User.query()
        case .Favorites:
            guard let searchUser = user else { break }
            
            query = searchUser.favoriteUsers?.query()
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
    
    func isFavoriteUser(user: User!, block: AVIntegerResultBlock!) {
        let query = favoriteUsers!.query()
        
        query.whereKey("objectId", equalTo: user.objectId)
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.countObjectsInBackgroundWithBlock(block)
    }
    
    func loadFavoriteUsers(block: AVArrayResultBlock!) {
        guard let favoriteUsers = self.favoriteUsers else {
            self.favoriteUsersArray.removeAll()
            block([], NSError(domain: "wumi.com", code: 1, userInfo: nil))
            return
        }
        
        // Load favorite users
        let query = favoriteUsers.query()
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            guard let favoriteUsers = results as? [User] else { return }
            
            self.favoriteUsersArray = favoriteUsers
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
        
        // Load saved posts
        let query = savedPosts.query()
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            guard let savedPosts = results as? [Post] else { return }
            
            self.savedPostsArray = savedPosts
            block(results, error)
        }
    }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.objectId == rhs.objectId
}

// MARK: User Search Type enum

enum UserSearchType {
    case All, Favorites, Graduation
}