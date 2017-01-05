//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Herman on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import AVOSCloud
import UIKit
import MapKit
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
    @NSManaged var countryCode: String?
    @NSManaged var favoriteUsers: AVRelation?
    @NSManaged var professions: [Profession]
    @NSManaged var savedPosts: AVRelation?
    @NSManaged var pushNotifications: AVRelation?
    
    // Properties should not be saved into PFUser
    /// Confirmed password string.
    var confirmPassword: String?
    lazy var favoriteUsersArray: [User] = []
    lazy var savedPostsArray: [Post] = []
    lazy var pushNotificationsArray: [PushNotification] = []
    var maxCacheAge: NSTimeInterval? = 3600 * 48
    var expireAt: NSDate? = nil
    
    var location: Location {
        get {
            return Location(CountryCode: self.countryCode, State: self.state, City: self.city)
        }
        set {
            self.countryCode = newValue.countryCode
            self.state = newValue.state
            self.city = newValue.city
        }
    }
    
    var nameDescription: String {
        return (self.name ?? "") + (self.graduationYear > 0 ? "(" + String(format: "%02d", self.graduationYear % 100) + ")" : "")
    }
    
    var shortUserBannerDesc: String {
        return self.nameDescription + (self.location.shortDiscription.characters.count > 0 ? ", " + self.location.shortDiscription : "")
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
    
    /**
     Validate user's profile data asynchronously with a block.
     
     - Parameters:
        - block: block includes validation results returned asynchronously.
                its first parameter indicates whether this user's profile is valid or not; 
                second parameter is a Wumi error array.
     
     */
    func validateUser(block: (valid: Bool, error: [WumiError]) -> Void) {
        var errors = [WumiError]()
        var errorMesage = ""
        
        // Validate user name
        if (!self.validateUserName(&errorMesage)) {
            errors.append(WumiError(type: .Name, error: errorMesage))
        }
        
        // Validate user password
        if (!self.validatePassword(&errorMesage)) {
            errors.append(WumiError(type: .Password, error: errorMesage))
        }
        
        // Validate confirmed password
        if (!self.validateConfirmPassword(&errorMesage)) {
            errors.append(WumiError(type: .ConfirmPassword, error: errorMesage))
        }
        
        block(valid: errors.count == 0, error: errors)
    }
    
    /**
     Validate user's name.
     
     - Parameters:
        - error: output parameter used to store error message.
     
     - Returns:
        True if user name is valid, otherwise false.
     */
    func validateUserName(inout error: String) -> Bool {
        guard let username = self.username else {
            error = Constants.SignIn.String.ErrorMessages.blankUsername
            return false
        }
        
        guard username.characters.count > 3 else {
            error = Constants.SignIn.String.ErrorMessages.shortUsername
            return false
        }
        
        return true
    }
    
    /**
     Validate user's password.
     
     - Parameters:
        - error: output parameter used to store error message.
     
     - Returns:
        True if user's password is valid, otherwise false.
     */
    func validatePassword(inout error: String) -> Bool {
        guard let password = self.password else {
            error = Constants.SignIn.String.ErrorMessages.blankPassword
            return false
        }
        
        guard password.characters.count > 3 else {
            error = Constants.SignIn.String.ErrorMessages.shortPassword
            return false
        }
        
        return true
    }
    
    /**
     Validate user's confirmed password.
     
     - Parameters:
        - error: output parameter used to store error message.
     
     - Returns:
        True if user's confirmed password is valid, otherwise false.
     */
    func validateConfirmPassword(inout error: String) -> Bool {
        guard let confirmPassword = self.confirmPassword else {
            error = Constants.SignIn.String.ErrorMessages.blankPassword
            return false
        }
        
        guard confirmPassword.characters.count > 3 else {
            error = Constants.SignIn.String.ErrorMessages.shortPassword
            return false
        }
        
        guard self.password == confirmPassword else {
            error = Constants.SignIn.String.ErrorMessages.passwordNotMatch
            return false
        }
        
        return true
    }
    
    // MARK: Avatar functions
 
    /**
     Load avatar of this user asynchorously.
     This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background.
     
     - Parameters:
        - scaleToSize: Scale avatar to a specific size.
        - block: Block includes result avatar image or a WumiError if failed.
     */
    func loadAvatar(scaleToSize size: CGSize? = nil, block: (avatar: UIImage?, error: WumiError?) -> Void) {
        guard let file = self.avatarImageFile else {
            block(avatar: nil, error: WumiError(type: .Image, error: "No avatar image for this user."))
            return
        }
        
        AVFile.loadImageFile(file, size: size) { (image, error) in
            block(avatar: image, error: ErrorHandler.parseError(error))
        }
    }
    
    /**
     Load avatar's thumbnail of this user asynchorously.
     This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background.
     
     - Parameters:
        - scaleToSize: Scale avatar to a specific size.
        - block: Block includes result avatar image or a WumiError if failed.
     */
    func loadAvatarThumbnail(ScaleToSize size: CGSize? = nil, block: (avatar: UIImage?, error: WumiError?) -> Void) {
        guard let file = self.avatarThumbnail else {
            block(avatar: nil, error: WumiError(type: .Image, error: "No avatar thumbnail image for this user."))
            return
        }
        
        AVFile.loadImageFile(file, size: size) { (image, error) in
            block(avatar: image, error: ErrorHandler.parseError(error))
        }
    }
    
    /** 
    Save avatar to cloud server asynchronously.
     
    - Parameters:
        - avatarImage: UIimage will be stored as avatar.
        - block: Block includes result of saving avatar to server
    */
    func saveAvatarFile(avatarImage: UIImage?, block: (success: Bool, error: WumiError?) -> Void) {
        guard let image = avatarImage else {
            block(success: false, error: WumiError(type: .Image, error: "Image is nil."))
            return
        }
        
        // Save original image
        AVFile.saveImageFile(&self.avatarImageFile, image: image) { (success, error) in
            guard success else {
                block(success: success, error: error)
                return
            }
            
            // Save thumbnail
            AVFile.saveImageFile(&self.avatarThumbnail,
                                 image: image,
                                 size: CGSize(width: Constants.General.Size.AvatarThumbnail.Width,
                                              height: Constants.General.Size.AvatarThumbnail.Height),
                                 block: block)
        }
    }
    
    // MARK: User queries
    
    /**
     Load user records asynchonously.
     
     - Parameters:
        - searchString: search text string.
        - limit: Limit of results returned.
        - type: Contact search type. The category is defined in ContactSearchType enum.
        - forUser: load user for a specific user.
        - sinceUser: Last user loaded. We will search from start if it is nil, otherwise, load more.
        - block: Block includes search results: array of user records or a WumiError record.
     */
    class func loadUsers(searchString searchString: String = "", limit: Int = 200, type: ContactSearchType = .All, forUser user: User? = nil, sinceUser lastUser: User? = nil, block: (users: [User], error: WumiError?) -> Void) {
        guard var query = User.getQueryFromSearchType(type, forUser: user) else {
            block(users: [], error: WumiError(type: .Query, error: "Failed in starting query"))
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
        if let lastUser = lastUser, indexQuery = User.getQueryFromSearchType(type, forUser: user), tieBreakerQuery = User.getQueryFromSearchType(type, forUser: user) {
            indexQuery.whereKey(index, greaterThan: lastUser[index])
            tieBreakerQuery.whereKey(index, equalTo: lastUser[index])
            tieBreakerQuery.whereKey("objectId", greaterThan: lastUser.objectId)
            query = AVQuery.orQueryWithSubqueries([indexQuery, tieBreakerQuery])
        }
        
        // Handler search string
        if !searchString.isEmpty {
            query.whereKey(index, containsString: searchString)
        }
        
        // Add filter based on search type
        if let user = user where type == .Graduation {
            query.whereKey("graduationYear", equalTo: user.graduationYear)
        }
        
        // Sort results by
        query.orderByAscending(index)
        query.addAscendingOrder("objectId")
        
        // Set limit
        query.limit = limit
        
        // Cache policy
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        // Search users
        query.findObjectsInBackgroundWithBlock { (results, error) in
            guard let users = results as? [User] where error == nil else {
                block(users: [], error: ErrorHandler.parseError(error))
                return
            }
            
            for user in users {
                User.cacheUserData(user)
            }
            block(users: users, error: nil)
        }
    }
    
    /**
     Load an user object based on object Id.
     
     - Parameters:
        - objectId: Object Id of the user to be fetched.
        - block: Block includes search results: a user record or a WumiError record if failed.
     */
    class func loadUserInBackground(objectId id: String, block: (user: User?, error: WumiError?) -> Void) {
        let query = User.query()
        query.includeKey("professions") // Also fetch associated professions
        
        // Cache policy
        query.cachePolicy = .CacheThenNetwork
        query.maxCacheAge = 3600 * 24 * 30
        
        // Load User
        query.getObjectInBackgroundWithId(id) { (result, error) in
            guard let user = result as? User where error == nil else {
                block(user: nil, error: ErrorHandler.parseError(error))
                return
            }
            
            User.cacheUserData(user)
            block(user: user, error: nil)
        }
    }
    
    // Fetch if needed. This function will fetch user data from memory first, then from network if it is null
    func loadIfNeededInBackgroundWithBlock(block: (user: User?, error: WumiError?) -> Void) {
        if self.isDataAvailable() {
            block(user: self, error: nil)
            return
        }
        
        // Try fetch data from memory by objectId
        if let user = DataManager.sharedDataManager.cache["user_" + self.objectId] as? User {
            print("Found \(user.name) in memory cache")
            block(user: user, error: nil)
            return
        }
        
        // Try fetch data from
        User.loadUserInBackground(objectId: self.objectId, block: block)
    }
    
    // Save the user and fetch latest data after saving
    func saveInBackgroundWithFetch(block: AVBooleanResultBlock!) {
        let option = AVSaveOption()
        option.fetchWhenSave = true
        self.saveInBackgroundWithOption(option, block: block)
    }
    
    /**
     Cache an user data into local memory.
     
     - Parameters:
        - user: User record to be cached.
     */
    class func cacheUserData(user: User) {
        // Set up cache age
        user.maxCacheAge = 3600 * 24
        
        DataManager.sharedDataManager.cache["user_" + user.objectId] = user
        
        DataManager.log("Cached \(user.name) in memory")
    }
    
    /**
     Get associated AVQuery object based on search type.
     
     - Parameters:
        - searchType: Contact search type. The category is defined in ContactSearchType.
        - forUser: Query for a specific user.
     
     - Returns:
        An AVQuery object for query. Nil if failed.
     */
    class func getQueryFromSearchType(searchType: ContactSearchType, forUser user: User? = nil) -> AVQuery? {
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
        self.professions.removeAll()
        self.professions.appendContentsOf(newProfessions)
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

/**
 Search category for contacts:
 
 * All: Search contacts from all users.
 * Favorites: Search contacts from favorited users of current login user.
 * Graduation: Search contacts from users graduated in same year.
 
 */
enum ContactSearchType {
    case All, Favorites, Graduation
}
