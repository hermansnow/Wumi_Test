//
//  WechatMomentsActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class WechatMomentsActivity: ShareActivity {
    
    override func activityTitle() -> String? {
        return "Moments"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Moments")
    }
    
    func activitySettingsImage() -> UIImage? {
        return UIImage(named: "Moments")
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
            WechatService.sharePost(post, scene: .Moments)
        }
    }
}