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
        if userIds.count > 0 {
            var query = User.query()
            var subQueries = [AVQuery]()
            for id in userIds {
                let subQuery = User.query()
                subQuery.whereKey("objectId", equalTo: id)
                subQueries.append(subQuery)
            }
            query = AVQuery.orQueryWithSubqueries(subQueries)
            
            query.limit = userIds.count
            // Cache policy
            query.cachePolicy = .NetworkElseCache
            query.maxCacheAge = 3600 * 24 * 30
            
            query.findObjectsInBackgroundWithBlock { (results, error) in
                if let users = results as? [User] where error == nil {
                    for user in users {
                        User.cacheUserData(user)
                    }
                    block(true, error)
                } else {
                    block(false, error)
                }
            }
        } else {
            block(true, nil)
        }
    }
    
    func getUserById(userId: String!) -> CDUserModelDelegate! {
        let imUser = IMUser()
        if let user = DataManager.sharedDataManager.cache["user_" + userId] as? User {
//            print("Found \(user.name) in memory cache")
            imUser.setUserId(userId)
            imUser.setUsername(user.name)
            imUser.setAvatarUrl(user.avatarThumbnail?.url)
            return imUser
        } else {
            if let user = AVQuery.getUserObjectWithId(userId) as? User {
                print("Get \(user.name) from cloud")
                imUser.setUserId(userId)
                imUser.setUsername(user.name)
                imUser.setAvatarUrl(user.avatarThumbnail?.url)
                return imUser
            }
            print("fail to find \(userId) in cache")
            imUser.setUserId(userId)
            imUser.setUsername(userId)
            imUser.setAvatarUrl("http://ac-x3o016bx.clouddn.com/86O7RAPx2BtTW5zgZTPGNwH9RZD5vNDtPm1YbIcu")
            return imUser
        }
    }
    
}