//
//  ActionButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/3/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
        self.addTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
        self.addTarget()
    }
    
    // MARK: Help functions
    
    /**
     Set properties for the button.
     */
    internal func setProperty() {
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
    }
    
    /**
     Add gesture handler.
     */
    internal func addTarget() {
        self.addTarget(self,
                       action: #selector(tapped(_:)),
                       forControlEvents: .TouchUpInside)
    }
    
    /**
     Event handler when button is clicked.
     */
    func tapped(sender: AnyObject) { }
}
