//
//  Post.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class Post: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var author: User?
    @NSManaged var title: String?
    @NSManaged var content: String?
    @NSManaged var htmlContent: String?
    @NSManaged var commentCount: Int
    @NSManaged var categories: [PostCategory]
    @NSManaged var mediaAttachments: [AVFile]
    @NSManaged var mediaThumbnails: [AVFile]
    @NSManaged var hasPreviewImage: Bool
    @NSManaged var location: AVGeoPoint?
    
    // Local properties, will not be stored into server
    var attributedContent: NSMutableAttributedString?
    var attachedImages = [UIImage]()
    var attachedThumbnails = [UIImage]()
    var externalPreviewImageUrl: NSURL?
    var area: Area?
    
    var url: String {
        get {
            return "https://wumi.herokuapp.com?p=\(self.objectId)"
        }
    }
    
    /// Whether this post has any thumbnail or not.
    var hasThumbnail: Bool {
        return self.attachedThumbnails.count > 0 || self.mediaThumbnails.count > 0
    }
    
    // MARK: Initializer and subclassing functions
    
    // Must have this init for subclassing AVObject
    override init() {
        super.init()
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass() // Register the subclass
        }
    }
    
    // Must have this class function for subclassing AVObject
    class func parseClassName() -> String? {
        return "Post"
    }
    
    // MARK: Queries
    
    /**
     Return number of new posts after a cut-off time.
     
     - Parameters:
        - filter: post search filter.
        - cutoffTime: cut-off time for determining post is new or not.
        - user: user to search.
        - block: closure includes number of new posts or a wumi error if failed.
     */
    class func countNewPosts(filter filter: PostSearchFilter, cutoffTime: NSDate? = nil, user: User? = nil, block: (Int, WumiError?) -> Void) {
        guard let query = Post.getQueryFromSearchType(filter.searchType, forUser: user) else {
            block(0, WumiError(type: .Query, error: "Failed in starting query"))
            return
        }
        
        // Sort based on last update time
        let index = "updatedAt"
        query.orderByDescending(index)
        
        // Load posts earlier than a cut-off timestamp
        if let cutoffTime = cutoffTime {
            query.whereKey(index, greaterThan: cutoffTime)
        }
        
        // Support custom filters
        if let category = filter.category where filter.searchType == .Filter {
            query.whereKey("categories", equalTo: category)
        }
        
        // Apply location filter
        if let area = filter.area where filter.searchType == .Filter {
            query.whereKey("location", nearGeoPoint: AVGeoPoint(latitude: area.latitude, longitude: area.longitude), withinMiles: 600.0)
        }
        
        // This search is network only, does not support cache
        query.cachePolicy = .NetworkOnly
        
        query.countObjectsInBackgroundWithBlock { (count, error) in
            block(count, ErrorHandler.parseError(error))
        }
    }
    
    /**
     Search post based on several filters asynchronously.
     
     - Parameters:
        - limit: limit of search result numbers.
        - filter: post search filter.
        - cutoffTime: cut-off time for determining post is new or not.
        - user: user to search.
        - block: closure includes array of result posts or a wumi error if failed.
     */
    class func loadPosts(limit limit: Int = 10, filter: PostSearchFilter, cutoffTime: NSDate? = nil, user: User? = nil, block: ([Post], WumiError?) -> Void) {
        guard var query = Post.getQueryFromSearchType(filter.searchType, forUser: user) else {
            block([], WumiError(type: .Query, error: "Failed in starting query"))
            return
        }
        
        // Handler search string
        if let titleQuery = Post.getQueryFromSearchType(filter.searchType, forUser: user),
            contentQuery = Post.getQueryFromSearchType(filter.searchType, forUser: user) where !filter.searchString.isEmpty {
            
            titleQuery.whereKey("title", matchesRegex: filter.searchString, modifiers: "im")
            contentQuery.whereKey("content", matchesRegex: filter.searchString, modifiers: "im")
            query = AVQuery.orQueryWithSubqueries([titleQuery, contentQuery])
        }
        
        // Sort based on last update time
        let index = "updatedAt"
        query.orderByDescending(index)
        
        // Load posts earlier than a cut-off timestamp
        if let cutoffTime = cutoffTime {
            query.whereKey(index, lessThan: cutoffTime)
        }
        
        // Apply category filter
        if let category = filter.category where filter.searchType == .Filter {
            query.whereKey("categories", equalTo: category)
        }
        
        // Apply location filter
        if let area = filter.area where filter.searchType == .Filter {
            query.whereKey("location", nearGeoPoint: AVGeoPoint(latitude: area.latitude, longitude: area.longitude), withinMiles: 600.0)
        }
        
        // Include relations
        query.includeKey("mediaThumbnails")
        query.includeKey("categories")
        
        // Set search limit
        query.limit = limit
        
        // Set cache policy
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24
        
        query.findObjectsInBackgroundWithBlock { (results, error) in
            guard let posts = results as? [Post] where error == nil else {
                block([], ErrorHandler.parseError(error))
                return
            }
            
            block(posts, nil)
        }
    }
    
    class func findPost(objectId id: String) -> Bool {
        let query = Post.query()
        
        query.whereKey("objectId", equalTo: id)
        
        return query.countObjects() > 0
        
    }
    
    // Fetch a post record asynchronously based on record id
    class func fetchInBackground(objectId id: String, block: AVObjectResultBlock!) {
        let query = Post.query()
        query.includeKey("mediaAttachments")
        query.includeKey("mediaThumbnails")
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.getObjectInBackgroundWithId(id) { (result, error) in
            guard let post = result as? Post where error == nil else {
                block(nil, error)
                return
            }
            
            post.decodeAttributedContent()
            
            post.loadContentWithBlock(requestPreviewImage: false) { (found, foundUrl) in
                post.loadMediaAttachmentsWithBlock { (success, error) in
                    guard success && error == nil else {
                        block(nil, error)
                        return
                    }
                    
                    block(post, error)
                }
            }
        }
    }
    
    /**
     Fetch external data for a post asynchronously in background.
     */
    func fetchDataInBackground() {
        // Fetch content if needed
        self.loadContentWithBlock(requestPreviewImage: true) { (_, _) in }
        
        // Load preview image from attachment media or external URL
        if self.hasThumbnail {
            self.loadFirstThumbnailWithBlock { (_, _) in }
        }
        
        // Fetch author information
        if let author = self.author {
            author.loadIfNeededInBackgroundWithBlock { (result, error) in
                guard let user = result where error == nil else { return }
                
                // Load avatar of author
                user.loadAvatarThumbnail { (_, _) in }
            }
        }
    }
    
    // Save a post record asynchronously
    override func saveInBackgroundWithBlock(block: AVBooleanResultBlock!) {
        // Set default value
        self.title = self.title ?? "No Title"
        self.commentCount = self.commentCount ?? 0
        
        // Set location
        if let area = self.area {
            self.location = AVGeoPoint(latitude: area.latitude, longitude: area.longitude)
        }
        
        // Parse URLS
        if let content = self.content {
            content.parseWebUrl({ (hasPreviewImage) in
                self.hasPreviewImage = hasPreviewImage
                
                // Save attached files
                if self.mediaAttachments.count == 0 {
                    self.saveMediaAttachmentsWithBlock { (success, error) in
                        guard success && error == nil else { return }
                        
                        super.saveInBackgroundWithBlock(block)
                    }
                }
                else {
                    super.saveInBackgroundWithBlock(block)
                }
            })
        }
    }
    
    // MARK: Post attachments queries
    
    // Save attached images as AVFiles synchronously
    private func saveMediaAttachmentsWithBlock(block: AVBooleanResultBlock!) {
        // Use dispatch_group to save a list of images
        let taskGroup = dispatch_group_create()
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        var images = [AVFile?](count: self.attachedImages.count, repeatedValue: nil)
        var thumbnails = [AVFile?](count: self.attachedImages.count, repeatedValue: nil)
        
        for index in 0..<self.attachedImages.count {
            guard let image = self.attachedImages[safe: index] else { continue }
            
            dispatch_group_async(taskGroup, taskQueue) {
                guard let file = AVFile.saveImageFile(image) else { return }
                
                images[index] = file
            }
            
            dispatch_group_async(taskGroup, taskQueue) {
                guard let thumbnail = AVFile.saveImageFile(image, size: CGSize(width: Constants.Post.Size.Thumbnail.Width, height: Constants.Post.Size.Thumbnail.Height)) else { return }
                
                thumbnails[index] = thumbnail
            }
        }
        
        dispatch_group_notify(taskGroup, taskQueue) { 
            guard let mediaAttachments = images.filter( { $0 != nil }) as? [AVFile] else {
                dispatch_async(dispatch_get_main_queue(), {
                    block(false, NSError(domain: "wumi.com", code: 0, userInfo: [:]))
                })
                return
            }
            
            self.mediaAttachments.removeAll()
            self.mediaAttachments.appendContentsOf(mediaAttachments)
            
            guard let mediaThumbnails = thumbnails.filter( { $0 != nil }) as? [AVFile] else {
                dispatch_async(dispatch_get_main_queue(), {
                    block(false, NSError(domain: "wumi.com", code: 0, userInfo: [:]))
                })
                return
            }
            
            self.mediaThumbnails.removeAll()
            self.mediaThumbnails.appendContentsOf(mediaThumbnails)
            
            dispatch_async(dispatch_get_main_queue(), {
                block(true, nil)
            })
        }
    }
    
    /**
     Load the first thumbnail asynchronously.
     
     - Parameters:
        - block: closure with an image if success or wumi error if failed.
     */
    func loadFirstThumbnailWithBlock(block: (UIImage?, WumiError?) -> Void) {
        // Return first image if we have any stored in local object
        if self.attachedThumbnails.count > 0 {
            block(self.attachedThumbnails.first, nil)
            return 
        }
        
        guard let firstImageFile = self.mediaThumbnails[safe: 0] else {
            block(nil, nil)
            return
        }
        
        AVFile.loadImageFile(firstImageFile) { (image, error) in
            guard error == nil else {
                block(nil, ErrorHandler.parseError(error))
                return
            }
            block(image, ErrorHandler.parseError(error))
        }
    }
    
    /**
     Load post content asynchronously.
     
     - Parameters:
        - requestPreviewImage: whether request preview image URL or not.
        - block: closure indicates whether we succssfully loaded content or not.
     */
    func loadContentWithBlock(requestPreviewImage requestPreviewImage: Bool, block: (isLoaded: Bool, foundUrl: Bool) -> Void) {
        guard let content = self.content else {
            block(isLoaded: false, foundUrl: false)
            return
        }
        
        self.attributedContent = PostTableViewCell.attributedText(NSAttributedString(string: content))
        self.attributedContent?.replaceLink(requestMetadataImage: requestPreviewImage) { (found, url) in
            self.externalPreviewImageUrl = url
            block(isLoaded: true, foundUrl: found)
        }
    }
    
    // Convert attached AVFiles to local images
    private func loadMediaAttachmentsWithBlock(block: AVBooleanResultBlock!) {
        // Use dispatch_group to save a list of images
        let taskGroup = dispatch_group_create()
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        var thumbnails = [UIImage?](count: self.mediaAttachments.count, repeatedValue: nil)
        
        for index in 0..<self.mediaAttachments.count {
            guard let thumbnail = self.mediaAttachments[safe: index] else { continue }
            
            dispatch_group_async(taskGroup, taskQueue) {
                guard let attachedThumbnail = AVFile.loadImageFile(thumbnail) else { return }
                
                thumbnails[index] = attachedThumbnail
            }
        }
        
        dispatch_group_notify(taskGroup, taskQueue) {
            guard let attachedThumbnails = thumbnails.filter( { $0 != nil }) as? [UIImage] else {
                dispatch_async(dispatch_get_main_queue(), {
                    block(false, NSError(domain: "wumi.com", code: 0, userInfo: [:]))
                })
                return
            }
            
            self.attachedImages.removeAll()
            self.attachedImages.appendContentsOf(attachedThumbnails)
            
            dispatch_async(dispatch_get_main_queue(), { 
                block(true, nil)
            })
        }
    }
    
    // Encode post's attributed content into a Html format
    private func encodeAttributedContent() {
        guard let attributedContent = self.attributedContent else { return }
        
        let modifiedContent = NSMutableAttributedString(attributedString: attributedContent)
        do {
            modifiedContent.enumerateAttribute(NSAttachmentAttributeName,
                                               inRange: NSRange(location: 0, length: modifiedContent.length),
                                               options: [],
                                               usingBlock: { (result, range, stop) in
                                                guard let attachment = result as? NSTextAttachment,
                                                    image = attachment.image,
                                                    file = AVFile.saveImageFile(image) else { return }
                                                
                                                modifiedContent.replaceCharactersInRange(range, withString: "[wumi_img:" + file.url + "]")
            })
            
            let htmlData = try modifiedContent.dataFromRange(NSRange(location: 0, length: modifiedContent.length),
                                                             documentAttributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType])
            let htmlString = String(data: htmlData, encoding: NSUTF8StringEncoding)
            
            self.htmlContent = htmlString
        }
        catch {
            print("Failed to encode attributed content")
        }
    }
    
    // Decode post's html content to attributed string
    private func decodeAttributedContent() {
        guard let htmlString = self.htmlContent, htmlData = htmlString.dataUsingEncoding(NSUTF8StringEncoding) else { return }
        
        do {
            let attributedContent = try NSMutableAttributedString(data: htmlData,
                                                                  options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                  documentAttributes: nil)
            let regex = try NSRegularExpression(pattern: "\\[wumi_img:[^\\]]*\\]", options:[.CaseInsensitive])
            let matches = regex.matchesInString(attributedContent.string, options: [],
                                                range: NSRange(location: 0, length: attributedContent.length))
                    
            for match in matches {
                attributedContent.replaceCharactersInRange(match.range, withString: "Here is an image")
            }
                    
            self.attributedContent = attributedContent
        }
        catch {
            print("Failed to decode the html content")
        }
    }
    
    // Load all users who saved this post
    func loadFavoriteUsers(block: AVArrayResultBlock!) {
        let query = User.query()
        query.whereKey("savedPosts", equalTo:self)
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24 * 30
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
    // Get associated AVQuery object based on search type
    class func getQueryFromSearchType(searchType: PostSearchType, forUser user: User? = nil) -> AVQuery? {
        var query: AVQuery? = nil
        
        switch (searchType) {
        case .All:
            query = Post.query()
        case .Saved:
            guard let searchUser = user else { break }
            
            query = searchUser.savedPosts!.query()
        case .Filter:
            query = Post.query()
        }
        
        return query
    }
}

// MARK: Equatable

func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.objectId == rhs.objectId
}

// MARK: Post Search structures

/**
 Enum for post search type:
    * All - search from all posts.
    * Saved - search from saved posts.
    * Filter - search with a custom filter.
 */
enum PostSearchType: String {
    /// Search from all posts.
    case All = "All"
    /// Search from saved posts.
    case Saved = "Saved"
    /// Search with a custom filter.
    case Filter = "Custom Filter"
    
    /// Array of all post search types.
    static let allTypes: [PostSearchType] = [.All, .Saved, .Filter]
    
    /// Array of all post search types' title.
    static var allTitles: [String] {
        var titles = [String]()
        for value in self.allTypes {
            titles.append(value.rawValue)
        }
        return titles
    }
}

/**
 Structure includes post search filter's criteria.
 */
struct PostSearchFilter {
    /// Search string of current search.
    var searchString: String = ""
    /// Short-cut search type of current search.
    var searchType: PostSearchType = .All
    /// Search by post category.
    var category: PostCategory?
    /// Search in a specific area.
    var area: Area?
    
    init() { }
    
    init(searchType: PostSearchType) {
        self.searchType = searchType
    }
    
    /**
     Whether this post search filter has custom filter (category or area) or not?
     
     - Returns:
        True if has custom filter, otherwise false.
     */
    func hasCustomFilter() -> Bool {
        return self.category != nil || self.area != nil
    }
    
    /**
     Clear post custom filters (category and area).
     */
    mutating func clearCustomFilter() {
        self.category = nil
        self.area = nil
    }
}
