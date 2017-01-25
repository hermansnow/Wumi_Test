//
//  Extension+String.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension String {
    func isMatch(regex: String, options: NSRegularExpressionOptions) -> Bool {
        do {
            let exp = try NSRegularExpression(pattern: regex, options: options)
            return exp.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)) > 0
        }
        catch {
            print("Failed in creating NSRegularExpression")
            return false
        }
    }
    
    /**
     Check whether this string contains Chinese characters or nor.
     
     - Returns:
        True if contains any Chinese character, otherwise false.
     */
    func containChinese() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\p{script=Han}", options: .AnchorsMatchLines)
            return regex.numberOfMatchesInString(self, options: [],
                                                 range: NSRange(location: 0, length: self.characters.count)) > 0
        }
        catch {
            ErrorHandler.log("Failed in creating NSRegularExpression for Han")
            return false
        }
    }
    
    // Check whether has web link
    func parseWebUrl(completionHandler: (hasPreviewImage: Bool) -> Void) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else {
            completionHandler(hasPreviewImage: false)
            return
        }
        
        let results = detector.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
        
        var urls = [NSURL]()
        let taskGroup = dispatch_group_create()
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL else { continue }
            
            dispatch_group_async(taskGroup, taskQueue) {
                // Add link description based on url
                if url.willOpenInApp() == nil {
                    url.fetchPageInfo() { (title, previewImageURL) in
                        if previewImageURL != nil {
                            urls.append(previewImageURL!)
                        }
                    }
                }
            }
        }
        
        dispatch_group_notify(taskGroup, taskQueue) {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(hasPreviewImage: urls.count > 0)
            }
        }
    }
    
    /**
     Return initial of an uppercase string composed with the first letter of first and last components of it, for example "HC" for "Herman Cheng".
     In terms of string with Chinese character, this api will only return the first character.
     
     - Returns:
        Initial string.
     */
    func initials() -> String {
        if self.containChinese() {
            return self.substringToIndex(self.startIndex.advancedBy(1))
        }
        
        let names = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var value = ""
        
        guard let firstName = names.first else {
            return value
        }
        
        value = firstName.substringToIndex(firstName.startIndex.advancedBy(1))
        
        if let lastName = names.last where names.count > 1 {
            value += " " + lastName.substringToIndex(lastName.startIndex.advancedBy(1))
        }
        
        return value.uppercaseString
    }
    
    /**
     Return Chinese pinyin string in lowcase.
     
     - Returns:
        Chinese pinyin string.
     */
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
