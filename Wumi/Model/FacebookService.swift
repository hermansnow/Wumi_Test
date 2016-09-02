//
//  FacebookService.swift
//  Wumi
//
//  Created by Zhe Cheng on 9/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

struct FacebookService {
    
    static private var appKey = "1836765936547463"
    
    static func sharePost(post: Post, fromViewController vc: UIViewController) {
        let url = post.url
        let fbLinkContent = FBSDKShareLinkContent()
        fbLinkContent.contentURL = NSURL(string: url)
        fbLinkContent.contentTitle = post.title
        if let content = post.content {
            let endIndex = content.characters.count > 100 ? 100 : content.characters.count
            fbLinkContent.contentDescription = content.substringToIndex(content.startIndex.advancedBy(endIndex))
        }
        else {
            fbLinkContent.contentDescription = "post from wumi"
        }
        if let previewImage = post.mediaAttachments.first {
            fbLinkContent.imageURL = NSURL(string: previewImage.url)
        }
        
        let dialog =  FBSDKShareDialog()
        dialog.fromViewController = vc
        dialog.shareContent = fbLinkContent
        dialog.mode = .Native
        dialog.show()
    }
}