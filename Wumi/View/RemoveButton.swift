//
//  RemoveButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class RemoveButton: ActionButton {
    /// Check button delegate.
    var delegate: RemoveButtonDelegate?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setImage(UIImage(named: Constants.General.ImageName.Remove),
                      forState: .Normal)
    }
    
    override func tapped(sender: AnyObject) {
        super.tapped(sender)
        
        guard let delegate = self.delegate else { return }
        
        delegate.remove(self)
    }
}

protocol RemoveButtonDelegate {
    /**
     Try handle remove action by clicking this remove button.
     
     - Parameters:
        - removeButton: Remove Button clicked.
     */
    func remove(removeButton: RemoveButton)
}

