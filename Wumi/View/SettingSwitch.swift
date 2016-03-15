//
//  SettingSwitch.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SettingSwitch: UISwitch {
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setProperty()
    }
    
    private func setProperty() {
        tintColor = Constants.General.Color.BackgroundColor
        onTintColor = Constants.General.Color.ThemeColor
    }
}
