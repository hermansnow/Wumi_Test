//
//  CopyLinkActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CopyLinkActivity: ActionActivity {
    override class func activityCategory() -> UIActivityCategory {
        return .Action
    }
    
    override func activityTitle() -> String? {
        return "Copy Link"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Link")
    }
    
    func activitySettingsImage() -> UIImage? {
        return UIImage(named: "Link")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if item is Post {
                return true
            }
        }
        return false
    }
    
    override func performActivity() {
        super.performActivity()
        
        if let post = self.post {
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = post.url
        }
    }
}
