//
//  ProfileCollectionCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var cellLabel: ProfileCollectionLabel!
    
    enum ProfessionCollectionCellStyle {
        case Original
        case Selected
    }
    
    var style = ProfessionCollectionCellStyle.Original {
        didSet {
            // Redisplay if value is changed
            if self.style != oldValue {
                switch (self.style) {
                case .Original:
                    self.cellLabel.backgroundColor = UIColor.whiteColor()
                    self.cellLabel.textColor = UIColor.blackColor()
                case .Selected:
                    self.cellLabel.backgroundColor = Constants.General.Color.ThemeColor
                    self.cellLabel.textColor = Constants.General.Color.TitleColor
                }
                self.cellLabel.setNeedsDisplay()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set properties
        self.cellLabel.backgroundColor = UIColor.whiteColor()
        self.cellLabel.textColor = UIColor.blackColor()
    }
}
