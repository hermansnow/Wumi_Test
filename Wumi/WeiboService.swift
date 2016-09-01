//
//  WeiboService.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct WeiboService {
    
    static private var appKey = "2493641654"
    static private var authRedirectURL = "https://api.weibo.com/oauth2/default.html"
    
    static func registerApp() {
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(WeiboService.appKey)
    }
    
    static func share(message: WBMessageObject, authRequest: WBAuthorizeRequest) {
        // Send message
        if let request = WBSendMessageToWeiboRequest.requestWithMessage(message, authInfo: authRequest, access_token: nil) as? WBSendMessageToWeiboRequest {
            request.shouldOpenWeiboAppInstallPageIfNotInstalled = true
            request.userInfo = nil
            
            WeiboSDK.sendRequest(request)
        }
    }
    
    static func sharePost(post: Post) {
        guard let message = WBMessageObject.message() as? WBMessageObject,
            authRequest = WBAuthorizeRequest.request() as? WBAuthorizeRequest else { return }
        
        // Collect auth
        authRequest.redirectURI = WeiboService.appKey
        authRequest.scope = "all"
        
        // Compost post weibo message
        let postPage = WBWebpageObject()
        postPage.objectID = "post.objectId"
        postPage.title = NSLocalizedString(post.title ?? "Wumi Post", comment: "")
        
        if let content = post.content {
            let endIndex = content.characters.count > 100 ? 100 : content.characters.count
            postPage.description = content.substringToIndex(content.startIndex.advancedBy(endIndex))
        }
        else {
            postPage.description = "post from wumi"
        }
        
        if let previewImage = post.attachedImages.first {
            postPage.thumbnailData = previewImage.scaleToSize(CGSize(width: 50,height: 50)).compressToSize(500)
        }
        else {
            postPage.thumbnailData = UIImage(named: "Logo")?.compressToSize(500)
        }
        postPage.webpageUrl = "https://wumi.herokuapp.com?&p=\(post.objectId)"
        
        message.text = "Shared from Wumi"
        message.mediaObject = postPage
        
        // Send message
        WeiboService.share(message, authRequest: authRequest)
    }
}