//
//  Extensions.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

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
}

extension UIImage {
    // Compress image in JPEG format. The max size of image save in Parse server is 10.0MB
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
    
    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    // Return current first responder
    public class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.sharedApplication().sendAction("findFirstResponder:", to: nil, from: nil, forEvent: nil)
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