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
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    override func drawRect(rect: CGRect) {
        
        contentView.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        contentView.layer.borderWidth = 5.0
        
        // Set default avatar
        avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
    }
}