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

    // MARK: Invitation code functions
    
    /**
     Generate a new invitation code asynchronously.
     
     - Parameters:
        - block: Block with a boolean flag to indicate whether generation succeed and a wumi error if failed.
     */
    func generateNewCode(block: (success: Bool, error: WumiError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // Generate new unique code
            repeat {
                self.invitationCode = self.randomAlphaNumericString(6)
            } while InvitationCode.findCode(self.invitationCode) != nil
            self.numberOfUse = 0
            
            dispatch_async(dispatch_get_main_queue(), { 
                // Store it into server
                self.saveInBackgroundWithBlock({ (success, error) in
                    block(success: success, error: ErrorHandler.parseError(error))
                })
            })
        }
    }
    
    /**
     Generate a random string.
     
     - Parameters:
        - length: Length of the string.
     */
    private func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        return randomString
    }
    
    // MARK: Query
    
    /**
     Verify this invitation code asynchronouslly.
     
     - Parameters:
        - block: Return closure block with a verified boolean flag and a wumi error message.
     */
    func verifyCodeWhithBlock(block: (verified: Bool, error: WumiError?) -> Void) {
        guard let inputCode = self.invitationCode else {
            block(verified: false, error: WumiError(type: .InvitationCode, error: Constants.SignIn.String.ErrorMessages.blankInvitationCode))
            return
        }
        
        // Internal Debug backdoor, TODO: Remove it before releasing
        if inputCode == "12345" {
            block(verified: true, error: nil)
        }
        else if let inviteCode = InvitationCode.findCode(inputCode) {
            inviteCode.incrementKey("numberOfUse")
            inviteCode.saveInBackground()
            block(verified: true, error: nil)
        }
        else {
            block(verified: false, error: WumiError(type: .InvitationCode, error: Constants.SignIn.String.ErrorMessages.invalidInvitationCode))
        }
    }
    
    /**
     Server query to get a valid invitation code object based on code string.
     
     - Parameters:
        - code: Invitation code string used for query.
     
     - Returns:
        An InvitationCode onject if found, otherwise nil.
     */
    class func findCode(code: String?) -> InvitationCode? {
        guard let invitationCode = code where !invitationCode.isEmpty else { return nil }
        
        let query = InvitationCode.query()
        query.cachePolicy = .IgnoreCache
        query.whereKey("invitationCode", equalTo: invitationCode)
        
        if let queryResults = query.findObjects(), resultCode = queryResults.first as? InvitationCode {
            return resultCode
        }
        else {
            return nil
        }

    }
}

// MARK: Equatable

func ==(lhs: InvitationCode, rhs: InvitationCode) -> Bool {
    return lhs.objectId == rhs.objectId
}
