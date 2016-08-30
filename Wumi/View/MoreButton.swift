//
//  MoreButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MoreButton: UIButton {
    
    var delegate: MoreButtonDelegate?
    
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
        self.setBackgroundImage(UIImage(named: "More"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "More_Selected"), forState: .Selected)
        
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
    }
    
    private func addTarget() {
        self.addTarget(self, action: #selector(tapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: ReplyButton) {
        guard let delegate = self.delegate else { return }
        
        delegate.showMoreActions(self)
    }
}

@objc protocol MoreButtonDelegate {
    func showMoreActions(moreButton: MoreButton)
}
