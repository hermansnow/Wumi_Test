//
//  ActionActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ActionActivity: UIActivity {

    var post: Post?
    
    override class func activityCategory() -> UIActivityCategory {
        return .Action
    }
    
    override func activityType() -> String? {
        return NSStringFromClass(self.classForCoder)
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if activityItems.count > 0 {
            return true
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            if let post = activityItem as? Post {
                self.post = post
            }
        }
    }
}
