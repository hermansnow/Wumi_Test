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
    
    // Fetch page information based on URL
    func fetchPageInfo(completion: ((title: String?, previewImageURL: NSURL?) -> Void)) {
        guard let doc = Ji(htmlURL: self) else {
            completion(title: nil, previewImageURL: nil)
            return
        }
            
        completion(title: self.getTitle(doc), previewImageURL: self.getOGImageUrl(doc))
    }
    
    // Open Graph title metadata
    private func getTitle(jiDoc: Ji) -> String? {
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
    private func getOGImageUrl(jiDoc: Ji) -> NSURL? {
        guard let jiDoc = Ji(htmlURL: self) else { return nil }
        
        if let nodes = jiDoc.xPath("//head/meta[@property='og:image']"),
            ogTitleNode = nodes.first,
            imageUrl = ogTitleNode.attributes["content"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return  NSURL(string: imageUrl)
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
        else if self.scheme.lowercaseString != "http" && self.scheme.lowercaseString != "https" &&
            !Constants.General.SchemeWhiteList.contains(self.scheme) && UIApplication.sharedApplication().canOpenURL(self) {
                return self.scheme
        }
        else {
            return nil
        }
    }
}
