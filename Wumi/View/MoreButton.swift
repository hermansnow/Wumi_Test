//
//  MoreButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MoreButton: ActionButton {
    
    /// More button delegate.
    var delegate: MoreButtonDelegate?
    
    // MARK: Help functions
    
    /**
     Set properties for the button.
     */
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.More),
                                forState: .Normal)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.More_Selected),
                                forState: .Selected)
    }
    
    /**
     Event handler when button is clicked.
     */
    override func tapped(sender: ActionButton) {
        super.tapped(sender)
        
        guard let _ = sender as? MoreButton, delegate = self.delegate else { return }
        
        delegate.showMoreActions(self)
    }
}

@objc protocol MoreButtonDelegate {
    
    /**
     Click more button to show more.
     
     - Parameters:
        - moreButton: The MoreButton object clicked.
     */
    func showMoreActions(moreButton: MoreButton)
}
