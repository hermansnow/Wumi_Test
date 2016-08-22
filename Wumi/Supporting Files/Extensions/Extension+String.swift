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
    
    // Check whether string contains Chinese characters
    func containChinese() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\p{script=Han}", options: .AnchorsMatchLines)
            return regex.numberOfMatchesInString(self, options: [], range: NSRange(location: 0, length: self.characters.count)) > 0
        }
        catch {
            print("Failed in creating NSRegularExpression for Han")
            return false
        }
    }
    
    // Check whether has web link
    func hasWebLink() -> Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else {
            return false
        }
        
        let results = detector.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL else { continue }
            
            if url.willOpenInApp() == nil && (url.scheme.lowercaseString == "http" || url.scheme.lowercaseString == "https")  {
                return true
            }
        }
        return false
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
