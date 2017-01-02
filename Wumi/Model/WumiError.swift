//
//  WumiError.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class WumiError: NSError {
    
    /// Wumi Error types.
    enum WumiErrorType {
        case Unknown
        case Name
        case Password
        case ConfirmPassword
        case Email
        case InvitationCode
        case Image
        case DisplayName
        case GraduationYear
    }
    
    /// Type of this Wumi error
    var type: WumiErrorType = .Unknown
    
    /// Error message
    var error: String? {
        guard let errorMessage = self.userInfo["error"] as? String else { return nil }
        
        return errorMessage
    }
    
    // MARK: Initializers
    
    convenience init(type: WumiErrorType, userInfo dict: [NSObject : AnyObject]?) {
        self.init(domain: "Wumi", code: 127, userInfo: dict)
        
        self.type = type
    }
    
    convenience init(type: WumiErrorType, error: String) {
        self.init(type: type, userInfo: ["error": error])
    }
    
    override init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
