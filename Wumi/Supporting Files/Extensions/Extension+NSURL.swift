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
            
        completion(title: self.getTitle(doc), previewImageURL: self.getImageUrl(doc))
    }
    
    // Title metadata
    private func getTitle(jiDoc: Ji) -> String? {
        // Try get title from og:title meta tag
        if let nodes = jiDoc.xPath("//head/meta[@property='og:title']"),
            ogTitleNode = nodes.first,
            content = ogTitleNode.attributes["content"] where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        // Try get title from general title tag
        else if let nodes = jiDoc.xPath("//head/title"),
            titleNode = nodes.first,
            content = titleNode.content where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        else {
            return nil
        }
    }
    
    // Image metadata
    private func getImageUrl(jiDoc: Ji) -> NSURL? {
        // Try get image from open graph metadata
        if let nodes = jiDoc.xPath("//head/meta[@property='og:image']"),
            ogImageNode = nodes.first,
            imageUrl = ogImageNode.attributes["content"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return  NSURL(string: imageUrl)
        }
        // Try get first image large than 300 * 300
        else if let nodes = jiDoc.xPath("//img") {
            var url: String?
            for imageNode in nodes {
                guard let width = imageNode.attributes["width"] where Int(width) > 100,
                    let height = imageNode.attributes["height"] where Int(height) > 100 else { continue }
                
                if let imageUrl = imageNode.attributes["href"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                    print(imageUrl)
                    url = imageUrl
                }
                if let imageSrc = imageNode.attributes["src"] where imageSrc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                    guard let host = self.host else { continue }
                    
                    if imageSrc.hasPrefix("/") {
                        url = self.scheme + ":" + host + imageSrc
                    }
                    if imageSrc.hasPrefix("//") {
                        url = self.scheme + ":" + imageSrc
                    }
                    else {
                        guard let path = self.path,
                            subPath = path.componentsSeparatedByString("/").first else { continue }
                        url = self.scheme + ":" + host + "/" + subPath + "/" + imageSrc
                    }
                }
                
                if url != nil {
                    print(url)
                    break
                }
            }
            
            if url != nil {
                return NSURL(string: url!)
            }
            else {
                return nil
            }
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
