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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set up the values for this button. It is
        // called here when the button first appears and is also called
        // from the main ViewController when the app is reset.
        
        setProperty()
    }
    
    func setProperty() {
        contentView.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        contentView.layer.borderWidth = 5.0
        
        // Set default avatar
        //avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
    }
}