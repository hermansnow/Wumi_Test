//
//  WechatService.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct WechatService {
    
    enum ShareScene {
        case Friends, Moments
    }
    
    static private var appID = "wxea5f3cc2562022ec"
    
    static func registerApp() {
        WXApi.registerApp(WechatService.appID)
    }
    
    static func share(message: WXMediaMessage, shareScene: ShareScene) {
        // Create request
        let request = SendMessageToWXReq()
        request.bText = false
        request.message = message
        
        switch shareScene {
        case .Friends:
            request.scene = Int32(WXSceneSession.rawValue)
        case .Moments:
            request.scene = Int32(WXSceneTimeline.rawValue)
        default:
            break
        }
        
        // Send message
        WXApi.sendReq(request)
    }
    
    // Compost weixin message for a post
    static func sharePost(post: Post, scene: ShareScene) {
        let message = WXMediaMessage()
        
        message.title = NSLocalizedString(post.title ?? "Wumi Post", comment: "")
        if let content = post.content {
            let endIndex = content.characters.count > 100 ? 100 : content.characters.count
            message.description = content.substringToIndex(content.startIndex.advancedBy(endIndex))
        }
        else {
            message.description = "post from wumi"
        }
        if let previewImage = post.attachedImages.first {
            message.setThumbImage(previewImage.scaleToSize(CGSize(width: 50,height: 50)))
        }
        else {
            message.setThumbImage(UIImage(named: "Logo")!)
        }
        
        // Add webpage object
        let postPage = WXWebpageObject()
        postPage.webpageUrl = post.url
        message.mediaObject = postPage
        
        // Send message
        WechatService.share(message, shareScene: scene)
    }
}
