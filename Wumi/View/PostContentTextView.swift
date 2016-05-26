//
//  PostContentTextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 5/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostContentTextView: UITextView {
    
    // MARK: Properties
    
    var selfUserInteractionEnabled: Bool = true // control user interaction of view itself but not subviews
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Help functions
    
    private func setProperty() {
        self.scrollEnabled = true
    }
    
    // Override hitTest function to only disable user interaction with this view but not subviews
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self && self.selfUserInteractionEnabled == false {
            return nil
        }
        else {
            return hitView
        }
    }
}