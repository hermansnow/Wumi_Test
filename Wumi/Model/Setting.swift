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
        case ButtonCell
        case DisplayCell
    }
    
    var identifier: String
    var title: String?
    var type: SettingType
    var detail: String?
    var relatedUserDefaultKey: String?
    var seletor: Selector?
    
    init(identifier: String, title: String?, type: SettingType, detail: String?, selector: Selector?, userDefaultKey: String?) {
        self.identifier = identifier
        self.title = title
        self.type = type
        self.detail = detail
        self.seletor = selector
        self.relatedUserDefaultKey = userDefaultKey
    }
}
