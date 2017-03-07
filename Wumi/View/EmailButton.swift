//
//  EmailButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class EmailButton: ActionButton {
    
    /// Email button delegate.
    var delegate: EmailButtonDelegate?
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Email),
                                forState: .Normal)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Email_Selected),
                                forState: .Highlighted)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Email_Selected),
                                forState: .Selected)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Email_Disabled),
                                forState: .Disabled)
    }
    
    override func tapped(sender: AnyObject) {
        super.tapped(sender)
        
        guard let delegate = self.delegate else { return }
        
        delegate.sendEmail(self)
    }
}

protocol EmailButtonDelegate {
    /**
     Try send an email by clicking this email button.
     
     - Parameters:
        - emailButton: Email Button clicked.
     */
    func sendEmail(emailButton: EmailButton)
}
