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
        setProperty()
        addTarget()
        
        super.drawRect(rect)
    }
    
    private func setProperty() {
        image = Constants.General.Image.Favorite
        imageColorOff = UIColor.brownColor()
        imageColorOn = Constants.General.Color.ThemeColor
        circleColor = Constants.General.Color.ThemeColor
        lineColor = Constants.General.Color.ThemeColor
        duration = 1.0 // default: 1.0
    }
    
    private func addTarget() {
        addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: FavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
            if delegate != nil {
                delegate!.removeFavorite(self)
            }
        }
        else {
            // select with animation
            sender.select()
            if delegate != nil {
                delegate!.addFavorite(self)
            }
        }
    }
}

@objc protocol FavoriteButtonDelegate {
    func addFavorite(favoriteButton: FavoriteButton)
    func removeFavorite(favoriteButton: FavoriteButton)
}
