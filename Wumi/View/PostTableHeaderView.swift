//
//  PostTableHeaderView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class PostTableHeaderView: UIStackView {
    // MARK: Initialzers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setProperty()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.backgroundColor = UIColor.blueColor()
        
        // Set up stack
        self.axis = .Vertical
        self.distribution = .Fill
        self.alignment = .Fill
        self.spacing = 3
    }
}
