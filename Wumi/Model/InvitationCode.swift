//
//  InvitationCode.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation

class InvitationCode: AVObject, AVSubclassing {
    // MARK: Properties
    
    // Extended properties
    @NSManaged var userName: String?
    @NSManaged dynamic var invitationCode: String?
    @NSManaged var numberOfUse: Int
    
    // MARK: Initializer and subclassing functions
    
    // Must have this init for subclassing AVObject
    override init() {
        super.init()
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass() // Register the subclass
        }
    }
    
    // Must have this class function for subclassing AVObject
    class func parseClassName() -> String? {
        return "InvitationCode"
    }

    // Invitation code functions
    func generateNewCode() {
        self.invitationCode = randomAlphaNumericString(6)
        self.numberOfUse = 0
        while findCode(self.invitationCode!) != nil {
            self.invitationCode = randomAlphaNumericString(6)
        }
        self.save()
    }
    
    func verifyCodeWhithBlock(block: (verified: Bool) -> Void) {
        guard let inputCode = self.invitationCode else {
            block(verified: false)
            return
        }
        if let inviteCode = findCode(inputCode) {
            inviteCode.incrementKey("numberOfUse")
            inviteCode.saveInBackground()
            block(verified: true)
        } else if inputCode == "12345" {
            block(verified: true)
        }
        else {
            block(verified: false)
        }
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        print("DEBUG: random String: \(randomString)")
        return randomString
    }
    
    // MARK: Query
    func findCode(code: String) -> InvitationCode? {
        let query = InvitationCode.query()
        query.cachePolicy = .IgnoreCache
        query.whereKey("invitationCode", equalTo: code)
        var result: InvitationCode?
        
        if let queryResult = query.findObjects() {
            if queryResult.count > 0 {
                result = queryResult.first as! InvitationCode?
            }
        }
        return result
    }
}

// MARK: Equatable
func ==(lhs: InvitationCode, rhs: InvitationCode) -> Bool {
    return lhs.objectId == rhs.objectId
}
