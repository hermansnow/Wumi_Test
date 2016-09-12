//
//  FacebookActivity.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class FacebookActivity: ShareActivity {

    override func activityTitle() -> String? {
        return "Facebook"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Facebook")
    }
    
    func activitySettingsImage() -> UIImage? {
        return UIImage(named: "Facebook")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if item is Post && self.rootVC != nil {
                return true
            }
        }
        return false
    }
    
    override func performActivity() {
        super.performActivity()
        
        if let post = self.post, vc = self.rootVC {
            FacebookService.sharePost(post, fromViewController: vc)
        }
    }
}
