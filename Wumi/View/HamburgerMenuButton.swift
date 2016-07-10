//
//  HamburgerMenuButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import SWRevealViewController

class HamburgerMenuButton: UIButton {
    
    var delegate: SWRevealViewController? {
        didSet {
            self.addTarget()
        }
    }
    
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
        self.setBackgroundImage(UIImage(named: "Hamburger_Menu"), forState: .Normal)
        self.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
    }
    
    private func addTarget() {
        guard let delegate = self.delegate else { return }
        
        self.addTarget(delegate, action: #selector(SWRevealViewController.revealToggle(_:)), forControlEvents: .TouchUpInside)
    }
}