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
    @IBOutlet weak var additionalButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.layer.borderWidth = 5.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.additionalButton.setBackgroundImage(UIImage(named: "More"), forState: .Normal)
        
        self.reset()
    }
    
    func reset() {
        self.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
        self.nameLabel.text = nil
        self.locationLabel.text = nil
        self.favoriteButton.selected = false
    }
}