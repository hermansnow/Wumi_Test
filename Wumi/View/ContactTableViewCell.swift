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
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoriteButton: DOFavoriteButton!
    
    var delegate: ContactTableViewCellDelegate?
    
    override func drawRect(rect: CGRect) {
        favoriteButton.imageColorOff = UIColor.brownColor()
        favoriteButton.imageColorOn = UIColor.orangeColor()
        favoriteButton.circleColor = UIColor.orangeColor()
        favoriteButton.lineColor = UIColor.orangeColor()
        favoriteButton.duration = 1.0 // default: 1.0
        
        favoriteButton.addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
        
        contentView.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).CGColor
        contentView.layer.borderWidth = 5.0
    }
    
    func tapped(sender: DOFavoriteButton) {
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

@objc protocol ContactTableViewCellDelegate: NSObjectProtocol {
    func addFavorite(cell: ContactTableViewCell);
    func removeFavorite(cell: ContactTableViewCell);
}