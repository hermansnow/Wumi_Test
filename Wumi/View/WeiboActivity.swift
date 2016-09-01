//
//  WeiboActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class WeiboActivity: ShareActivity {
    
    override func activityTitle() -> String? {
        return "Sina Weibo"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Weibo")
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
            WeiboService.sharePost(post)
        }
    }
}
