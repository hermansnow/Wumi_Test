//
//  Extension+UIImage.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import PhotosUI

extension UIImage {
    // Compress image in JPEG format. The max size of image save in server is 10.0MB
    func compressToSize(size: Int) -> NSData? {
        var compress:CGFloat = 1.0
        var imageData:NSData?
        
        if let jpegData = UIImageJPEGRepresentation(self, compress) {
            compress = CGFloat(size) / CGFloat(jpegData.length)
            if compress < 1.0 {
                imageData = UIImageJPEGRepresentation(self, compress);
            }
            else {
                imageData = jpegData
            }
        }
        return imageData;
    }
    
    // Scale an image to a specific size
    func scaleToSize(size: CGSize, aspectRatio: Bool = true) -> UIImage {
        var scaleSize = size
        if aspectRatio {
            var scaleFactor = size.width / self.size.width
            let newHeight = self.size.height * scaleFactor
            
            if newHeight > size.height {
                scaleFactor = size.height / self.size.height
                scaleSize = CGSize(width: self.size.width * scaleFactor, height: size.height)
            }
            else {
                scaleSize = CGSize(width: size.width, height: newHeight)
            }
        }
        
        return scale(scaleSize)
    }
    
    func scaleToWidth(width: CGFloat) -> UIImage {
        let scaleFactor = width / self.size.width
        let newHeight = self.size.height * scaleFactor
        let scaleSize = CGSize(width: width, height: newHeight)
        
        return scale(scaleSize)
    }
    
    func scaleToHeight(height: CGFloat) -> UIImage {
        let scaleFactor = height / self.size.height
        let newWidth = self.size.width * scaleFactor
        let scaleSize = CGSize(width: newWidth, height: height)
        
        return scale(scaleSize)
    }
    
    private func scale(scaleSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
        self.drawInRect(CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // Save an image into device's regular album of photo library
    func saveToLibrary(album albumName: String?, completionHanlder handler: ((PHAsset?, NSError?) -> Void)?){
        self.fetchAlbum(album: albumName) { (album, error) in
            guard let assetCollection = album where error == nil else { return }
            
            // Save image to the album
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var assetPlaceholder: PHObjectPlaceholder?
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self)
                    assetPlaceholder = assetRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection)
                    
                    albumChangeRequest!.addAssets([assetPlaceholder!])
                    }, completionHandler: { (success, error) in
                        guard let placeholder = assetPlaceholder where success && error == nil else {
                            dispatch_async(dispatch_get_main_queue(), {
                                if handler != nil {
                                    handler!(nil, error)
                                }
                            })
                            return
                        }
                        
                        let assets:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([placeholder.localIdentifier], options: nil)
                        
                        if let asset = assets.firstObject as? PHAsset {
                            dispatch_async(dispatch_get_main_queue(), {
                                if handler != nil {
                                    handler!(asset, error)
                                }
                            })
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), {
                                if handler != nil {
                                    handler!(nil, error)
                                }
                            })
                        }
                })
            }
        }
    }
    
    // Fetch an album from photo library
    private func fetchAlbum(album albumName: String?, completionHanlder handler: (PHAssetCollection?, NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let fetchOptions = PHFetchOptions()
            if albumName != nil {
                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName!)
            }
            
            // Get album
            var album: PHAssetCollection?
            if let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: nil).firstObject as? PHAssetCollection {
                album = collection
            }
                // If not found - Then create a new album
            else if albumName != nil {
                var assetPlaceholder: PHObjectPlaceholder?
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName!)
                    assetPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                    }, completionHandler: { success, error in
                        guard let placeholder = assetPlaceholder where success && error == nil else {
                            handler(nil, error)
                            return
                        }
                        
                        if let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([placeholder.localIdentifier], options: nil).firstObject as? PHAssetCollection {
                            album = collection
                        }
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                handler(album, nil)
            })
        }
    }
}