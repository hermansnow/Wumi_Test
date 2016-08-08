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
    
    // Local properties, will not be stored into server
    var attributedContent: NSAttributedString?
    var attachedImages = [UIImage]()
    var attachedThumbnails = [UIImage]()
    
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
    class func countNewPosts(type: PostSearchType = .All, cutoffTime: NSDate? = nil, user: User? = nil, block: AVIntegerResultBlock!) {
        guard let query = Post.getQueryFromSearchType(type, forUser: user) else {
            block(0, NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Failed in starting query"]))
            return
        }
        
        let index = "updatedAt" // Sort based on last update time
        
        // Load posts earlier than a cut-off timestamp
        if let cutoffTime = cutoffTime {
            query.whereKey(index, greaterThan: cutoffTime)
        }
        
        query.orderByDescending(index)
        query.cachePolicy = .NetworkOnly
        
        query.countObjectsInBackgroundWithBlock(block)
    }
    
    // Search post based on several filters
    class func loadPosts(limit limit: Int = 10, type: PostSearchType = .All, cutoffTime: NSDate? = nil, searchString: String = "", user: User? = nil, category: PostCategory? = nil, block: AVArrayResultBlock!) {
        guard var query = Post.getQueryFromSearchType(type, forUser: user) else {
            block([], NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Failed in starting query"]))
            return
        }
        
        // Handler search string
        if let titleQuery = Post.getQueryFromSearchType(type, forUser: user), contentQuery = Post.getQueryFromSearchType(type, forUser: user) where !searchString.isEmpty {
            titleQuery.whereKey("title", matchesRegex: searchString, modifiers: "im")
            contentQuery.whereKey("content", matchesRegex: searchString, modifiers: "im")
            query = AVQuery.orQueryWithSubqueries([titleQuery, contentQuery])
        }
        
        let index = "updatedAt" // Sort based on last update time
        
        // Load posts earlier than a cut-off timestamp
        if let cutoffTime = cutoffTime {
            query.whereKey(index, lessThan: cutoffTime)
        }
        
        if let category = category where type == .Filter {
            query.whereKey("categories", equalTo: category)
        }
        
        // Include relations
        query.includeKey("mediaThumbnails")
        query.includeKey("categories")
        
        query.orderByDescending(index)
        
        query.limit = limit
        
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 3600 * 24
        
        query.findObjectsInBackgroundWithBlock(block)
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
            post.loadMediaAttachmentsWithBlock { (success, error) in
                guard success && error == nil else { return }
                
                block(post, error)
            }
        }
    }
    
    // Save a post record asynchronously
    override func saveInBackgroundWithBlock(block: AVBooleanResultBlock!) {
        // Set default value
        self.title = self.title ?? "No Title"
        self.commentCount = self.commentCount ?? 0
            
        // Save attached files
        if self.htmlContent == nil {
            self.encodeAttributedContent() // TODO: Please make this function async when turning on the feature
        }
        if self.mediaAttachments.count == 0 {
            self.saveMediaAttachmentsWithBlock { (success, error) in
                guard success && error == nil else { return }
            
                super.saveInBackgroundWithBlock(block)
            }
        }
        else {
            super.saveInBackgroundWithBlock(block)
        }
    }
    
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
    
    func loadFirstThumbnailWithBlock(block: AVImageResultBlock) {
        guard self.attachedThumbnails.count == 0 else {
            block(self.attachedThumbnails.first, nil)
            return 
        }
        guard let firstImageFile = self.mediaThumbnails[safe: 0] else {
            block(nil, NSError(domain: "wumi.com", code: 0, userInfo: [:]))
            return
        }
        
        AVFile.loadImageFile(firstImageFile, block: block)
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

// MARK: Post Search Type enum

enum PostSearchType {
    case All
    case Saved
    case Filter
}
