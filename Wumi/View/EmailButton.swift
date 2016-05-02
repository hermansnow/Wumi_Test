//
//  EmailButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class EmailButton: UIButton {
    
    var delegate: EmailButtonDelegate?
    
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
    
    private func setProperty() {
        self.setBackgroundImage(UIImage(named: "Email"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "Email_Selected"), forState: .Highlighted)
        self.setBackgroundImage(UIImage(named: "Email_Selected"), forState: .Selected)
        self.setBackgroundImage(UIImage(named: "Email_Inactive"), forState: .Disabled)
        
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
    }
    
    private func addTarget() {
        self.addTarget(self, action: #selector(tapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: FavoriteButton) {
        guard let delegate = self.delegate else { return }
        
        delegate.sendEmail(self)
    }
}

protocol EmailButtonDelegate {
    func sendEmail(emailButton: EmailButton)
}