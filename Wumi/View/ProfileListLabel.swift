//
//  ProfileListLabel.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileListLabel: UILabel {
    
    override func drawRect(rect: CGRect) {
        Constants.General.Color.ThemeColor.setFill()
        UIRectFill(rect)
        
        textColor = Constants.General.Color.TitleColor
        font = Constants.General.Font.ButtonFont
        
        super.drawRect(rect)
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += 20
        return size
    }
    
}
