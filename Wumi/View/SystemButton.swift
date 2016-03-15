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
            setBackgroundColor()
            setNeedsDisplay()
        }
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set up the values for this button. It is
        // called here when the button first appears and is also called
        // from the main ViewController when the app is reset.
        
        setProperty()
    }
    
    func setProperty() {
        layer.cornerRadius = 3
        
        setTitleColor(Constants.General.Color.TitleColor, forState: .Normal)
        titleLabel?.font = Constants.General.Font.ButtonFont
        
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        if recommanded {
            layer.backgroundColor = Constants.General.Color.ThemeColor.CGColor
        }
        else {
            layer.backgroundColor = Constants.General.Color.BackgroundColor.CGColor
        }
    }
}
