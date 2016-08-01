//
//  Extension+NSURL.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension NSURL {
    
    func willOpen() -> Bool {
        let urlString = self.absoluteString
        
        print(self)
        print(self.scheme)
        
        // iTunes: App Store link: [itunes.apple.com]
        if urlString.isMatch("\\/\\/itunes\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return true
        }
        // Apple map: [maps.apple.com]
        if urlString.isMatch("\\/\\/maps\\.apple\\.com\\/", options: [.CaseInsensitive]) && UIApplication.sharedApplication().canOpenURL(self) {
            return true
        }
        // Protocol/URL-Scheme without http(s)
        else if self.scheme.caseInsensitiveCompare("http") != .OrderedSame && self.scheme.caseInsensitiveCompare("https") != .OrderedSame &&
            !Constants.General.SchemeWhiteList.contains(self.scheme) && UIApplication.sharedApplication().canOpenURL(self) {
                return true
        }
        
        return false
    }
}
