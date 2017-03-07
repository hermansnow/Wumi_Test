//
//  PhoneButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PhoneButton: ActionButton {
    
    /// Phone button delegate.
    var delegate: PhoneButtonDelegate?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Phone),
                                forState: .Normal)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Phone_Selected),
                                forState: .Highlighted)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Phone_Selected),
                                forState: .Selected)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Phone_Disabled),
                                forState: .Disabled)
    }
    
    override func tapped(sender: AnyObject) {
        super.tapped(sender)
        
        guard let delegate = self.delegate else { return }
        
        delegate.callPhone(self)
    }
}

protocol PhoneButtonDelegate {
    /**
     Try call a number by clicking this phone button.
     
     - Parameters:
        - phoneButton: Phone Button clicked.
     */
    func callPhone(phoneButton: PhoneButton)
}
