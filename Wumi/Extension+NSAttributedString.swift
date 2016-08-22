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
    func replaceLink(completionHandler: (linkFound: Bool, previewImageUrl: NSURL?) -> Void) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else { return }
        
        let results = detector.matchesInString(self.string, options: [], range: NSMakeRange(0, self.string.characters.count))
        
        var urls = [NSURL]()
        let taskGroup = dispatch_group_create()
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL else { continue }
            
            dispatch_group_async(taskGroup, taskQueue) {
                // Add link icon
                let textAttachment = NSTextAttachment()
                textAttachment.image = UIImage(named: "Link")?.scaleToHeight((Constants.Post.Font.ListContent?.capHeight)!)
                let urlImageString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
                    
                // Add link description based on url
                if let app = url.willOpenInApp() {
                    urlImageString.appendAttributedString(NSAttributedString(string: " \(app)"))
                }
                else {
                    url.fetchPageInfo { (title, previewImageURL) in                        
                        urlImageString.appendAttributedString(NSAttributedString(string: " \(title ?? url.absoluteURL)"))
                    
                        // Store preview images
                        if let imageURL = previewImageURL {
                            urls.append(imageURL)
                        }
                    }
                }
                
                // Replace the url string with short string (icon with a description)
                let range = NSRange(location: 0, length: urlImageString.length)
                urlImageString.removeAttribute(NSFontAttributeName, range: range)
                urlImageString.addAttribute(NSFontAttributeName, value: Constants.Post.Font.ListContent!, range: range)
                urlImageString.addAttribute(NSLinkAttributeName, value: url, range: range)
                
                self.replaceCharactersInRange(linkResult.range, withAttributedString: urlImageString)
            }
        }
        
        dispatch_group_notify(taskGroup, taskQueue) {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(linkFound: results.count > 0, previewImageUrl: urls.first)
            }
        }

    }
}
