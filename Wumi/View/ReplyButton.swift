//
//  ReplyButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ReplyButton: ActionButton {
    
    /// reply button delegate.
    var delegate: ReplyButtonDelegate?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Reply),
                                forState: .Normal)
    }
    
    override func tapped(sender: AnyObject) {
        guard let delegate = self.delegate else { return }
        
        delegate.reply(self)
    }
}

@objc protocol ReplyButtonDelegate {
    func reply(replyButton: ReplyButton)
}
