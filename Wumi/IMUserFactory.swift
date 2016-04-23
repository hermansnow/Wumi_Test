//
//  IMUserFactory.swift
//  Wumi
//
//  Created by JunpengLuo on 4/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class IMUserFactory: NSObject, CDUserDelegate {
    func cacheUserByIds(userIds: Set<NSObject>!, block: AVBooleanResultBlock!) {
        block(true, nil)
    }
    
    func getUserById(userId: String!) -> CDUserModelDelegate! {
        let user = IMUser()
        user.setUserId(userId)
        user.setUsername(userId)
        user.setAvatarUrl("http://ac-x3o016bx.clouddn.com/86O7RAPx2BtTW5zgZTPGNwH9RZD5vNDtPm1YbIcu")
        return user
    }
    
}