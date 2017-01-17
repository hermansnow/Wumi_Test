//
//  Setting.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

struct Setting {
    public enum SettingType {
        case Disclosure
        case Switch
        case Picker
        case Button
        case DisplayOnly
        case Input
    }
    
    var identifier: String
    var type: SettingType
    var name: String?
    var value: String?
    var relatedUserDefaultKey: String?
    var seletor: Selector?
    
    init(identifier: String, type: SettingType, value: String?) {
        self.identifier = identifier
        self.type = type
        self.name = identifier
        self.value = value
    }
    
    init(identifier: String, type: SettingType, name: String?, value: String?) {
        self.identifier = identifier
        self.type = type
        self.name = name
        self.value = value
    }
}
