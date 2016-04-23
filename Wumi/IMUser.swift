//
//  IMUser.swift
//  Wumi
//
//  Created by JunpengLuo on 4/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class IMUser: NSObject, CDUserModelDelegate {
    private var _username: String!
    private var _userId: String!
    private var _avatarUrl: String!
    
    func username() -> String! {
        return _username
    }
    
    func userId() -> String! {
        return _userId
    }
    
    func avatarUrl() -> String! {
        return _avatarUrl
    }
    
    func setUsername(username: String!) {
        _username = username
    }
    
    func setUserId(userId: String!) {
        _userId = userId
    }
    
    func setAvatarUrl(avatarUrl: String!) {
        _avatarUrl = avatarUrl
    }
}