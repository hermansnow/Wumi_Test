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
            switch (self.style) {
            case .Original:
                self.cellLabel.backgroundColor = Constants.General.Color.TitleColor
                self.backgroundColor = Constants.General.Color.TitleColor
                self.cellLabel.textColor = Constants.General.Color.TextColor
            case .Selected:
                self.cellLabel.backgroundColor = Constants.General.Color.ThemeColor
                self.backgroundColor = Constants.General.Color.ThemeColor
                self.cellLabel.textColor = Constants.General.Color.TitleColor
            }
            // Redisplay if value is changed
            if self.style != oldValue {
                self.cellLabel.setNeedsDisplay()
            }
        }
    }
    
    var width: CGFloat {
        get {
            return self.cellLabel.bounds.size.width
        }
        set {
            if self.cellLabel.bounds.size.width != newValue {
                self.cellLabel.bounds.size.width = newValue
                self.sizeToFit()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set properties
        self.style = .Original
        self.cellLabel.font = Constants.General.Font.ProfileCollectionFont
        self.layer.borderColor = Constants.General.Color.ThemeColor.CGColor
        self.layer.borderWidth = 1.0
    }
}
