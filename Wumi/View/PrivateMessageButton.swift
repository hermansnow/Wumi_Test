//
//  PrivateMessageButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PrivateMessageButton: ActionButton {

    /// PrivateMessage button delegate.
    var delegate: PrivateMessageButtonDelegate?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Private_Message),
                                forState: .Normal)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Private_Message_Selected),
                                forState: .Highlighted)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Private_Message_Selected),
                                forState: .Selected)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Private_Message_Disabled),
                                forState: .Disabled)
    }
    
    override func tapped(sender: AnyObject) {
        super.tapped(sender)
        
        guard let delegate = self.delegate else { return }
        
        delegate.sendMessage(self)
    }
}

protocol PrivateMessageButtonDelegate {
    /**
     Try send an private message by clicking this button.
     
     - Parameters:
        - privateMessageButton: PrivateMessage Button clicked.
     */
    func sendMessage(privateMessageButton: PrivateMessageButton)
}
