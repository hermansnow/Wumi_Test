//
//  Setting.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class Setting: NSObject {
    enum SettingType {
        case DisclosureCell
        case SwitchCell
        case NumberInputCell
    }
    
    var title: String?
    var type: SettingType
    var showDetailText = false
    var relatedUserDefaultKey: String?
    
    init(title: String, type: SettingType, showDetailText: Bool, userDefaultKey: String) {
        self.title = title
        self.type = type
        self.showDetailText = showDetailText
        self.relatedUserDefaultKey = userDefaultKey
    }
    
}
