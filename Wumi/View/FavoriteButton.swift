//
//  FavoriteButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class FavoriteButton: DOFavoriteButton {
    
    var delegate: FavoriteButtonDelegate?
    
    override func drawRect(rect: CGRect) {
        self.setProperty()
        self.addTarget()
        
        super.drawRect(rect)
    }
    
    private func setProperty() {
        self.image = Constants.General.Image.Favorite
        self.imageColorOff = UIColor.brownColor()
        self.imageColorOn = Constants.General.Color.ThemeColor
        self.circleColor = Constants.General.Color.ThemeColor
        self.lineColor = Constants.General.Color.ThemeColor
        self.duration = 1.0 // default: 1.0
    }
    
    private func addTarget() {
        self.addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: FavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
            if let delegate = self.delegate {
                delegate.removeFavorite(self)
            }
        }
        else {
            // select with animation
            sender.select()
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
