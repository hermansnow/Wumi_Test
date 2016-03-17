//
//  ProfileCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        
        self.selectionStyle = .None
    }
}