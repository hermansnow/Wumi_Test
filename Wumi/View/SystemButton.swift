//
//  SystemButton.swift
//  Wumi
//
//  Created by Herman on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class SystemButton: UIButton {
    
    var recommanded = true {
        didSet {
            self.setBackgroundColor()
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
    
    func setProperty() {
        self.layer.cornerRadius = 3
        
        self.setTitleColor(Constants.General.Color.TitleColor, forState: .Normal)
        self.titleLabel!.font = Constants.General.Font.ButtonFont
        
        self.setBackgroundColor()
    }
    
    func setBackgroundColor() {
        if self.recommanded {
            self.layer.backgroundColor = Constants.General.Color.ThemeColor.CGColor
        }
        else {
            self.layer.backgroundColor = Constants.General.Color.BackgroundColor.CGColor
        }
    }
}
