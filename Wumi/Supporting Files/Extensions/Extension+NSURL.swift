//
//  Extension+NSURL.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import Ji

extension NSURL {
    
    // Open Graph title metadata
    var ogTitle: String? {
        guard let jiDoc = Ji(htmlURL: self) else { return nil }
        
        if let nodes = jiDoc.xPath("//head/meta[@property='og:title']"),
            ogTitleNode = nodes.first,
            content = ogTitleNode.attributes["content"] where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        else if let nodes = jiDoc.xPath("//head/title"),
            titleNode = nodes.first,
            content = titleNode.content where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        else {
            return nil
        }
    }
    
    // Open Graph image metadata
    var ogImage: UIImage? {
        guard let jiDoc = Ji(htmlURL: self) else { return nil }
        
        if let nodes = jiDoc.xPath("//head/meta[@property='og:image']"),
            ogTitleNode = nodes.first,
            imageUrl = ogTitleNode.attributes["content"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0,
            let url = NSURL(string: imageUrl),
            data = NSData(contentsOfURL: url) {
                return UIImage(data: data)
        }
        else {
            return nil
        }
    }
    
    // Check whether URL can be opened from an installed app
    func willOpenInApp() -> String? {
        let urlString = self.absoluteString
        
        // iTunes: App Store link: [itunes.apple.com]
        if urlString.isMatch("\\/\\/itunes\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return "Itunes"
        }
        // Apple map: [maps.apple.com]
        if urlString.isMatch("\\/\\/maps\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return "Apple Map"
        }
        // Protocol/URL-Scheme without http(s)
        else if self.scheme.caseInsensitiveCompare("http") != .OrderedSame && self.scheme.caseInsensitiveCompare("https") != .OrderedSame &&
            !Constants.General.SchemeWhiteList.contains(self.scheme) && UIApplication.sharedApplication().canOpenURL(self) {
                return self.scheme
        }
        else {
            return nil
        }
    }
}
