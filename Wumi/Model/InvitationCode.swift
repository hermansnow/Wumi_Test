//
//  InvitationCode.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Parse

class InvitationCode: PFObject, PFSubclassing {
    
    dynamic var invitationCode: String?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass() // Register the subclass
        }
    }
    
    static func parseClassName() -> String {
        return "InvitationCode"
    }
    
    func verifyCodeWhithBlock(block: (verified: Bool) -> Void) {
        if (self.invitationCode == "12345") {
            block(verified: true)
        }
        else {
            block(verified: false)
        }
    }
    
    
}
