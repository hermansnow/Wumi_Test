//
//  TextLinkButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class TextLinkButton: UIButton {
    
    var textLinkFont = Constants.General.Font.LinkButtonFont {
        didSet {
            self.titleLabel!.font = self.textLinkFont
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Initializers
    
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
    
    private func setProperty() {
        self.setTitleColor(Constants.General.Color.ThemeColor, forState: .Normal)
        self.titleLabel!.font = self.textLinkFont
    }
}
