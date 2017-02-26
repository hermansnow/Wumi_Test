//
//  CheckButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 2/25/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class CheckButton: ActionButton {

    /// Check button delegate.
    var delegate: CheckButtonDelegate?
    /// Indexpath for button
    var indexPath: NSIndexPath?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setImage(UIImage(named: Constants.General.ImageName.Check),
                      forState: .Selected)
        self.setImage(UIImage(named: Constants.General.ImageName.Uncheck),
                      forState: .Normal)
    }
    
    override func tapped(sender: ActionButton) {
        super.tapped(sender)
        
        guard let _ = sender as? CheckButton, delegate = self.delegate else { return }
        
        delegate.check(self)
    }
}

protocol CheckButtonDelegate {
    /**
     Try call a number by clicking this check button.
     
     - Parameters:
        - checkButton: Check Button clicked.
     */
    func check(checkButton: CheckButton)
}

