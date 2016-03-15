//
//  ProfileCollectionLabel.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileCollectionLabel: UILabel {
    
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
    
    func setProperty() {
        // Set border
        layer.borderColor = Constants.General.Color.ThemeColor.CGColor
        layer.borderWidth = 1.0
        
        // Set properties
        font = Constants.General.Font.ButtonFont
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 2, left: 10, bottom: 2, right: 10)
        
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += 20
        size.height += 4
        return size
    }
    
}
