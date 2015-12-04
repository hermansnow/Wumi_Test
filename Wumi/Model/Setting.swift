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
        case Disclosure
        case Switch
        case Picker
        case Button
        case PlainText
    }
    
    var identifier: String
    var type: SettingType
    var name: String?
    var value: String?
    var relatedUserDefaultKey: String?
    var seletor: Selector?
    
    init(identifier: String, type: SettingType) {
        self.identifier = identifier
        self.type = type
    }
    
    init(identifier: String, type: SettingType, name: String?, value: String?) {
        self.identifier = identifier
        self.type = type
        self.name = name
        self.value = value
    }
}
