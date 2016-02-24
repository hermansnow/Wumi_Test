//
//  ContactTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: DOFavoriteButton!
    
    override func drawRect(rect: CGRect) {
        favoriteButton.imageColorOff = UIColor.brownColor()
        favoriteButton.imageColorOn = UIColor.redColor()
        favoriteButton.circleColor = UIColor.greenColor()
        favoriteButton.lineColor = UIColor.blueColor()
        favoriteButton.duration = 3.0 // default: 1.0
        
        favoriteButton.addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: DOFavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
        } else {
            // select with animation
            sender.select()
        }
    }
    
}
