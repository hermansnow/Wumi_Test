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
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.tintColor = Constants.General.Color.BackgroundColor
        self.onTintColor = Constants.General.Color.ThemeColor
    }
}
