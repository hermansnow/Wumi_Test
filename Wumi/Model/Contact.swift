//
//  Contact.swift
//  Wumi
//
//  Created by Herman on 2/5/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import AVOSCloud

class Contact: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var avatarImageFile: AVFile?
    @NSManaged var city: String?
    @NSManaged var country: String?
    
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
        return "Contact"
    }
    
    // Load avatar. This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background
    func loadAvatar(size: CGSize, WithBlock block: AVImageResultBlock!) {
        if avatarImageFile == nil {
            if block != nil {
                block!(nil, NSError(domain: "wumi.com", code: 1, userInfo: nil))
            }
            return
        }
        
        avatarImageFile?.getThumbnail(true, width: Int32(size.width), height: Int32(size.height), withBlock: block)
    }
    
    // Save avatar to cloud server
    func saveAvatarFile(avatarImage: UIImage?, WithBlock block: (success: Bool, error: NSError?) -> Void) {
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
    
    class func loadAllContact(skip: Int, WithBlock block: AVArrayResultBlock!) {
        let query = Contact.query()
        query.cachePolicy = .NetworkElseCache
        query.maxCacheAge = 24 * 3600
        
        query.skip = skip
        
        query.findObjectsInBackgroundWithBlock(block)
    }
}
