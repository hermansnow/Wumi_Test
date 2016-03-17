//
//  ProfessionSectionHeader.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfessionSectionHeader: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = UIFont(name: ".SFUIText-Bold", size: 14)
        self.titleLabel.textColor = Constants.General.Color.InputTextColor
    }
    
}
