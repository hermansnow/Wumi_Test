//
//  Extension+UITextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/17/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension UITextView {
    // Replace URL link with a short link
    func replaceLink() {
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else { return }
        
        let results = detector.matchesInString(self.text, options: [], range: NSMakeRange(0, self.text.characters.count))
        let attributeString = NSMutableAttributedString(attributedString: self.attributedText)
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL else { continue }
            
            // Add link icon
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "Link")?.scaleToHeight((Constants.Post.Font.ListContent?.capHeight)!)
            let urlImageString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
            
            // Add link description based on url
            if let app = url.willOpenInApp() {
                urlImageString.appendAttributedString(NSAttributedString(string: " \(app)"))
            }
            else {
                urlImageString.appendAttributedString(NSAttributedString(string: " \(url.ogImage ?? url.absoluteURL)"))
            }
            
            // Replace the url string with short string (icon with a description)
            let range = NSRange(location: 0, length: urlImageString.length)
            urlImageString.removeAttribute(NSFontAttributeName, range: range)
            urlImageString.addAttribute(NSFontAttributeName, value: Constants.Post.Font.ListContent!, range: range)
            urlImageString.addAttribute(NSLinkAttributeName, value: url, range: range)
            
            attributeString.replaceCharactersInRange(linkResult.range, withAttributedString: urlImageString)
        }
        self.attributedText = attributeString
    }
    
    // Preview images from links in the text view
    var linkImages: [UIImage] {
        var images = [UIImage]()
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else { return images }
        
        let results = detector.matchesInString(self.text, options: [], range: NSMakeRange(0, self.text.characters.count))
        
        for linkResult in results.reverse() {
            guard linkResult.resultType == NSTextCheckingType.Link, let url = linkResult.URL, image = url.ogImage else { continue }
            
            images.append(image)
        }
        
        return images
    }
}