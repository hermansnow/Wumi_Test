//
//  PostSelectedFilterView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class PostSelectedFilterView: UIView {
    /// Stackview for filters
    private var filterStackView = UIStackView()

    // MARK: Initialzers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.backgroundColor = UIColor.yellowColor()
        
        // Set up stack
        self.filterStackView.axis = .Horizontal
        self.filterStackView.distribution = .Fill
        self.filterStackView.alignment = .Center
        self.filterStackView.spacing = 3
    }
    
    /**
     Private function to be called after initialization to set up its subviews's layout.
     */
    private func setLayout() {
        // Layout for filter stackview
        self.filterStackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        self.filterStackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        self.filterStackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        self.filterStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        self.filterStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addFilter(filter: String) {
        let filterView = FilterView()
        filterView.text = filter
        self.filterStackView.insertArrangedSubview(filterView, atIndex: self.filterStackView.arrangedSubviews.count)
    }
}

class FilterView: UILabel {
    /// Remove icon's height
    private var iconHeight: CGFloat = 16
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: self.iconHeight / 2,
                                       left: self.iconHeight / 2,
                                       bottom: self.iconHeight / 2,
                                       right: self.iconHeight / 2)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.backgroundColor = UIColor.greenColor()
        self.clipsToBounds = true
        
        // Add remove icon
        let removeIcon = RemoveButton(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: self.iconHeight,
                                                    height: self.iconHeight))
        self.addSubview(removeIcon)
        self.bringSubviewToFront(removeIcon)
        
        // Add action to remove image when click remove icon.
        //removeIcon.delegate = self
    }
}
