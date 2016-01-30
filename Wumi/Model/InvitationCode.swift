//
//  InvitationCode.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation

class InvitationCode {
    
    dynamic var invitationCode: String?
    
    func verifyCodeWhithBlock(block: (verified: Bool) -> Void) {
        if (self.invitationCode == "12345") {
            block(verified: true)
        }
        else {
            block(verified: false)
        }
    }
    
    
}
