//
//  LocationTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/17/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    /// Cell title.
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    /// Cell detail string.
    var detail: String? {
        get {
            return self.detailLabel.text
        }
        set {
            self.detailLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set font and color
        self.titleLabel.font = Constants.General.Font.ProfileTextFont
        self.titleLabel.textColor = Constants.General.Color.TextColor
        self.detailLabel.font = Constants.General.Font.ProfileTitleFont
        self.detailLabel.textColor = Constants.General.Color.ProfileTitleColor
    }
    
    // MARK: Help Functions
    
    /**
     Reset cell data.
     */
    func reset() {
        self.title = nil
        self.detail = nil
        self.accessoryType = .None
        self.selectionStyle = .Default
    }
}
