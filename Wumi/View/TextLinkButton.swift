//
//  TextLinkButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class TextLinkButton: UIButton {
    
    lazy var textLinkFont = Constants.General.Font.LinkButtonFont
    
    override func drawRect(rect: CGRect) {
        setTitleColor(Constants.General.Color.ThemeColor, forState: .Normal)
        titleLabel?.font = textLinkFont
        
        super.drawRect(rect)
    }
}
