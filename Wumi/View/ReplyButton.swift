//
//  ReplyButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ReplyButton: UIButton {
    
    var delegate: ReplyButtonDelegate?
    
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
        self.setBackgroundImage(UIImage(named: "Reply"), forState: .Normal)
        
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
    }
    
    private func addTarget() {
        self.addTarget(self, action: #selector(tapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: ReplyButton) {
        guard let delegate = self.delegate else { return }
        
        delegate.reply(self)
    }
}

@objc protocol ReplyButtonDelegate {
    func reply(replyButton: ReplyButton)
}
