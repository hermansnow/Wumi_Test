//
//  TextLinkButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class TextLinkButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        setTitleColor(Constants.UI.ThemeColor, forState: .Normal)
        titleLabel?.font = UIFont(name: ".SFUIText-Medium", size: 14)
        
    }
}
