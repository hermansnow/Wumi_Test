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
        setTitleColor(Constants.General.Color.ThemeColor, forState: .Normal)
        titleLabel?.font = textLinkFont
    }
    
    override func drawRect(rect: CGRect) {
        titleLabel?.font = textLinkFont
        
        super.drawRect(rect)
    }
}
