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
            if style != oldValue {
                switch (style) {
                case .Original:
                    cellLabel.backgroundColor = UIColor.whiteColor()
                    cellLabel.textColor = UIColor.blackColor()
                case .Selected:
                    cellLabel.backgroundColor = Constants.General.Color.ThemeColor
                    cellLabel.textColor = Constants.General.Color.TitleColor
                }
                cellLabel.setNeedsDisplay()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set properties
        cellLabel.backgroundColor = UIColor.whiteColor()
        cellLabel.textColor = UIColor.blackColor()
    }
}
