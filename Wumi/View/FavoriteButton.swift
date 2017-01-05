//
//  FavoriteButton.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class FavoriteButton: ActionButton {
    
    /// Favorite button delegate.
    var delegate: FavoriteButtonDelegate?
    
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
    
    internal override func setProperty() {
        super.setProperty()
        
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Unfavorite),
                                forState: .Normal)
        self.setBackgroundImage(UIImage(named: Constants.General.ImageName.Favorite),
                                forState: .Selected)
    }
    
    override func tapped(sender: ActionButton) {
        super.tapped(sender)
        
        guard let button = sender as? FavoriteButton, delegate = self.delegate else { return }
        
        if button.selected {
            delegate.removeFavorite(self)
        }
        else {
            delegate.addFavorite(self)
        }
    }
}

@objc protocol FavoriteButtonDelegate {
    /**
     Add a record as favorite by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func addFavorite(favoriteButton: FavoriteButton)
    
    /**
     Remove a favorited record by clicking this favorite button.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
     */
    func removeFavorite(favoriteButton: FavoriteButton)
    
    /**
     Function to be triggered when a selected status of this button is changed.
     
     - Parameters:
        - favoriteButton: Favorite Button is clicked.
        - selected: New selected value for this button.
     */
    optional func didChangeSelected(favoriteButton: FavoriteButton, selected: Bool)
}
