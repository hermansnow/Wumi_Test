//
//  Extension+NSURL.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Kanna

extension NSURL {
    
    // Fetch page information based on URL
    func fetchPageInfo(requirePreviewImage requirePreviewImage: Bool =  true, completion: ((title: String?, previewImageURL: NSURL?) -> Void)) {
        
        var htmlContent: String?
        
        do {
            htmlContent = try String(contentsOfURL: self, encoding: NSUTF8StringEncoding)
        }
        catch { }
        
        guard let html = htmlContent, doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) else {
            completion(title: nil, previewImageURL: nil)
            return
        }
        
        if requirePreviewImage {
            completion(title: self.getTitle(doc), previewImageURL: self.getImageUrl(doc))
        }
        else {
            completion(title: self.getTitle(doc), previewImageURL: nil)
        }
    }
    
    // Title metadata
    private func getTitle(doc: HTMLDocument) -> String? {
        // Try get title from og:title meta tag
        let ogNodes = doc.xpath("//head/meta[@property='og:title']")
        if let ogTitleNode = ogNodes.first,
            content = ogTitleNode["content"] where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        // Try get title from general title tag
        let nodes = doc.xpath("//head/title")
        if let titleNode = nodes.first,
            content = titleNode.content where content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        return nil
    }
    
    // Image metadata
    private func getImageUrl(doc: HTMLDocument) -> NSURL? {
        // Try get image from open graph metadata
        let ogNodes = doc.xpath("//head/meta[@property='og:image']")
        if let ogImageNode = ogNodes.first,
            imageUrl = ogImageNode["content"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                return  NSURL(string: imageUrl)
        }
        
        // Try get first image large than 300 * 300
        var url: String?
        for imageNode in doc.xpath("//img") {
            guard let width = imageNode["width"] where Int(width) > 300,
                let height = imageNode["height"] where Int(height) > 300 else { continue }
                
            if let imageUrl = imageNode["href"] where imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                url = imageUrl
            }
            if let imageSrc = imageNode["src"] where imageSrc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                guard let host = self.host, scheme = self.scheme else { continue }
                    
                if imageSrc.hasPrefix("http://") || imageSrc.hasPrefix("https://") {
                    url = imageSrc
                }
                else if imageSrc.hasPrefix("/") {
                    url = scheme + ":" + host + imageSrc
                }
                else if imageSrc.hasPrefix("//") {
                    url = scheme + ":" + imageSrc
                }
                else {
                    guard let path = self.path,
                        subPath = path.componentsSeparatedByString("/").first else { continue }
                    url = scheme + ":" + host + "/" + subPath + "/" + imageSrc
                }
            }
                
            if url != nil {
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
    
    // Check whether URL can be opened from an installed app
    func willOpenInApp() -> String? {
        let urlString = self.absoluteString
        
        // iTunes: App Store link: [itunes.apple.com]
        if urlString!.isMatch("\\/\\/itunes\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return "Itunes"
        }
        // Apple map: [maps.apple.com]
        if urlString!.isMatch("\\/\\/maps\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return "Apple Map"
        }
        // Protocol/URL-Scheme without http(s)
        else if self.scheme!.lowercaseString != "http" && self.scheme!.lowercaseString != "https" &&
            !Constants.General.SchemeWhiteList.contains(self.scheme!) && UIApplication.sharedApplication().canOpenURL(self) {
                return self.scheme
        }
        else {
            return nil
        }
    }
}
