//
//  FavoriteButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    
    var delegate: FavoriteButtonDelegate?
    
    // MARK: Initializers
    
    override var selected: Bool {
        get {
           return super.selected
        }
        set {
            if let delegate = self.delegate, didChangeSelected = delegate.didChangeSelected where newValue != super.selected {
                didChangeSelected(self, selected: newValue)
            }
            super.selected = newValue
        }
    }
    
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
        self.setBackgroundImage(UIImage(named: "Star"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "Star_Selected"), forState: .Selected)
        
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
    }
    
    private func addTarget() {
        self.addTarget(self, action: #selector(tapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: FavoriteButton) {
        if sender.selected {
            if let delegate = self.delegate {
                delegate.removeFavorite(self)
            }
        }
        else {
            if let delegate = self.delegate {
                delegate.addFavorite(self)
            }
        }
    }
}

@objc protocol FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton)
    func removeFavorite(favoriteButton: FavoriteButton)
    optional func didChangeSelected(favoriteButton: FavoriteButton, selected: Bool)
}
