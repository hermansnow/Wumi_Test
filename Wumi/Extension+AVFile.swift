//
//  Extension+AVFile.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension AVFile {
    // Load avatar. This function will check whether the image in in local cache first. If not, then try download it from Leancloud server asynchronously in background
    class func loadImageFile(file: AVFile, size: CGSize? = nil, block: AVImageResultBlock!) {
        file.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            // create a queue to parse image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                guard error == nil else {
                    block(nil, error)
                    return
                }
                
                let image = parseDataToImage(imageData, size: size)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    block(image, error)
                })
            })
        }
    }
    
    // Load image AVfile synchronously
    class func loadImageFile(file: AVFile, size: CGSize? = nil) -> UIImage? {
        let imageData = file.getData()
        return parseDataToImage(imageData, size: size)
    }
    
    // Save avatar to cloud server asynchronously
    class func saveImageFile(inout file: AVFile?, image: UIImage, name: String? = nil, size: CGSize? = nil, block: (success: Bool, error: NSError?) -> Void) {
        // Scale image
        let resizedImage: UIImage
        if size != nil {
            resizedImage = image.scaleToSize(size!)
        }
        else {
            resizedImage = image
        }
        
        // Compress the image data if it excesses the max size defined for server (5 MB).
        guard let imageData = resizedImage.compressToSize(500) else {
            block(success: false, error: NSError(domain: "wumi.com", code: 1, userInfo: ["message": "Cannot scale image"]))
            return
        }
        
        // Set file name
        if let imageName = name {
            file = AVFile(name: imageName, data: imageData)
        }
        else {
            file = AVFile(data: imageData)
        }
        
        // Save file
        if file != nil {
            file!.saveInBackgroundWithBlock(block)
        }
    }
    
    // Save avatar to cloud server synchronously
    class func saveImageFile(image: UIImage, name: String? = nil, size: CGSize? = nil) -> AVFile? {
        // Scale image
        let resizedImage: UIImage
        if size != nil {
            resizedImage = image.scaleToSize(size!)
        }
        else {
            resizedImage = image
        }
        
        // Compress the image data if it excesses the max size defined for server (5 MB).
        guard let imageData = resizedImage.compressToSize(500) else {
            return nil
        }
        
        // Set file name
        var file: AVFile?
        if let imageName = name {
            file = AVFile(name: imageName, data: imageData)
        }
        else {
            file = AVFile(data: imageData)
        }
        
        // Save file
        if file != nil {
            file!.save()
        }
        
        return file
    }
    
    // Parse a NSData to an UIImage object with specific size
    private class func parseDataToImage(data: NSData?, size: CGSize? = nil) -> UIImage? {
        var image: UIImage?
        
        if let imageData = data, originalImage = UIImage(data: imageData) {
            if size != nil {
                image = originalImage.scaleToSize(size!)
            }
            else {
                image = originalImage
            }
        }
        
        return image
    }
}
