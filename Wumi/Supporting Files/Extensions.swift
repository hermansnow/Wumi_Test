//
//  Extensions.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import Photos

extension NSObject {
    @objc func selfMethod() -> NSObject {
        return self
    }
}

extension Array {
    // Subscript to get element from index safely without overflow crash
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    // Group array elements based on a sepcific key
    func groupBy<Key: Hashable>(group: (Element) -> Key) -> [Key: [Element]] {
        var result = [Key: [Element]]()
        
        for element in self {
            let groupKey = group(element)
            
            if result[groupKey] == nil {
                result[groupKey] = [Element]()
            }
            result[groupKey]?.append(element)
        }
        
        return result
    }
    
    mutating func appendUniqueObject<T: Equatable>(object: T) {
        for index in indices.sort(>) {
            if let element = self[index] as? T where element == object { return }
        }
        self.append(object as! Element)
    }
    
    // Remove list of items
    mutating func removeAtIndexes(indexes:[Int]) -> () {
        for index in indexes.sort(>) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObject<T: Equatable>(object: T) {
        for index in indices.sort(>) {
            guard let element = self[index] as? T where element == object else { continue }
            self.removeAtIndex(index)
        }
    }
}

extension Set {
    // Subscript to get element from set from a specific index
    subscript(index index: Int) -> Element? {
        return self[startIndex.advancedBy(index)]
    }
    
    // Map a set to an array
    func toArray <T: Hashable>(map: (Element) -> T?) -> Set<T> {
        var result = Set<T>()
        
        for element in self {
            if let value = map(element) {
                result.insert(value)
            }
        }
        
        return result
    }
}

extension String {
    // Check whether string contains Chinese characters
    func containChinese() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\p{script=Han}", options: .AnchorsMatchLines)
            return regex.numberOfMatchesInString(self, options: [], range: NSRange(location: 0, length: self.characters.count)) > 0
        } catch {
            print("Failed in creating NSRegularExpression for Han")
            return false
        }
    }
    
    // Return Chinese pinyin lowcase string
    func toChinesePinyin() -> String {
        // Try parse the name as Mandarin Chinese
        let formatingStr = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(formatingStr, nil, kCFStringTransformMandarinLatin, false) && CFStringTransform(formatingStr, nil, kCFStringTransformStripDiacritics, false) {
            return (formatingStr as String).lowercaseString
        }
        else {
            return self.lowercaseString
        }
    }
    
    // Return height of a string
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func getSizeWithFont(font: UIFont)->CGSize {
        
        let textSize = NSString(string: self ?? "").sizeWithAttributes([NSFontAttributeName: font])
        
        return textSize
    }
}

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
        
        UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
        self.drawInRect(CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // Save an image into device's regular album of photo library
    func saveToLibrary(completionHanlder handler: (PHAsset?, NSError?) -> Void){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            guard let assetCollection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: nil).firstObject as? PHAssetCollection else { return }
            
            var assetPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self)
                assetPlaceholder = assetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection)
                
                albumChangeRequest!.addAssets([assetPlaceholder!])
                }, completionHandler: { (success, error) in
                    guard let placeholder = assetPlaceholder where success && error == nil else {
                        dispatch_async(dispatch_get_main_queue(), {
                            handler(nil, error)
                        })
                        return
                    }
                    
                    let assets:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([placeholder.localIdentifier], options: nil)
                    
                    if let asset = assets.firstObject as? PHAsset {
                        dispatch_async(dispatch_get_main_queue(), {
                            handler(asset, error)
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            handler(nil, error)
                        })
                    }
            })
        }
    }
}

extension UIViewController {
    // Dismiss inputView when touching any other areas on the screen
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func dismissInputView() {
        self.view.endEditing(true)
    }
}

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    // Return current first responder
    public class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.sharedApplication().sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, forEvent: nil)
        return UIResponder._currentFirstResponder
    }
    
    internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}

extension UITextField {
    // Return next responding textfield based on tag order
    func nextResponderTextField() -> UITextField? {
        let nextTag = self.tag + 1;
            
        // Try to find next responder
        guard let rootView = self.window, nextResponder = rootView.viewWithTag(nextTag) as? UITextField else { return nil }
            
        return nextResponder
    }
    
    // a computed property for setting left space of textfield
    var leftSpacing: CGFloat {
        get {
            if let leftView = self.leftView {
                return leftView.frame.size.width
            }
            else {
                return 0
            }
        }
        set {
            let leftSpacingFrame = CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height)
            if let leftView = self.leftView {
                leftView.frame = leftSpacingFrame
            }
            else {
                self.leftView = UIView(frame: leftSpacingFrame)
            }
            self.leftViewMode = .Always
        }
    }
}