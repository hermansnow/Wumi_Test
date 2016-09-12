//
//  WechatFriendsActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class WechatFriendsActivity: ShareActivity {
    
    override func activityTitle() -> String? {
        return "Friends"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Wechat")
    }
    
    func activitySettingsImage() -> UIImage? {
        return UIImage(named: "Wechat")
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
            WechatService.sharePost(post, scene: .Friends)
        }
    }
}
