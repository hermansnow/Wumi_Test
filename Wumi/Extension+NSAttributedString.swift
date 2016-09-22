//
//  Extension+NSAttributedString.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    // Highlight specific string in the attributed string
    func highlightString(highlightedString: String?) {
        guard let keywords = highlightedString where keywords.characters.count > 0 else { return }
        
        do {
            let regex = try NSRegularExpression(pattern: keywords, options: .CaseInsensitive)
            
            for match in regex.matchesInString(self.string, options: [], range: NSRange(location: 0, length: self.string.utf16.count)) as [NSTextCheckingResult] {
                self.addAttribute(NSForegroundColorAttributeName,
                                  value: Constants.General.Color.ThemeColor,
                                  range: match.range)
            }
        } catch {
            print("Failed in creating NSRegularExpression for string matching")
        }
    }
    
    // Replace URL link with a short title
    func replaceLink(requirePreviewImage requirePreviewImage: Bool, completionHandler: (linkFound: Bool, previewImageUrl: NSURL?) -> Void) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else { return }
        
        let results = detector.matchesInString(self.string, options: [], range: NSMakeRange(0, self.string.characters.count))
        
        var urls = [NSURL]()
        var urlReplaceDict = [NSTextCheckingResult: NSAttributedString]()
        let taskGroup = dispatch_group_create()
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL else { continue }
            
            dispatch_group_async(taskGroup, taskQueue) {
                let urlString = NSMutableAttributedString()
                    
                // Add link description based on url
                if let app = url.willOpenInApp() {
                    urlString.appendAttributedString(NSAttributedString(string: " \(app)"))
                }
                else {
                    url.fetchPageInfo(requirePreviewImage: requirePreviewImage) { (title, previewImageURL) in
                        urlString.appendAttributedString(NSAttributedString(string: " \(title ?? url.absoluteURL)"))
                    
                        // Store preview images
                        if let imageURL = previewImageURL {
                            urls.append(imageURL)
                        }
                    }
                }
                
                // Replace the url string with short string (icon with a description)
                let range = NSRange(location: 0, length: urlString.length)
                urlString.removeAttribute(NSFontAttributeName, range: range)
                urlString.addAttribute(NSFontAttributeName, value: Constants.Post.Font.ListContent, range: range)
                urlString.addAttribute(NSLinkAttributeName, value: url, range: range)
                
                urlReplaceDict[linkResult] = urlString
            }
        }
        
        dispatch_group_notify(taskGroup, taskQueue) {
            for linkResult in results.reverse() {
                guard let urlString = urlReplaceDict[linkResult] else { continue }
                
                self.replaceCharactersInRange(linkResult.range, withAttributedString: urlString)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(linkFound: results.count > 0, previewImageUrl: urls.first)
            }
        }
    }
}
