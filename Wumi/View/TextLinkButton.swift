//
//  TextLinkButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class TextLinkButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        setTitleColor(Constants.UI.Color.ThemeColor, forState: .Normal)
        titleLabel?.font = UIFont(name: ".SFUIText-Medium", size: 14)
        
        super.drawRect(rect)
    }
}
