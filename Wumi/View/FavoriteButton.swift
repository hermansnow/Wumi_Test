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
    
    override func drawRect(rect: CGRect) {
        self.setProperty()
        self.addTarget()
        
        super.drawRect(rect)
    }
    
    private func setProperty() {
        self.setBackgroundImage(UIImage(named: "Unfavorite"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "Favorite"), forState: .Selected)
        
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = true
    }
    
    private func addTarget() {
        self.addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
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

protocol FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton)
    func removeFavorite(favoriteButton: FavoriteButton)
}
