//
//  ContactLabelCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactLabelCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet var actionButtons: [UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = Constants.General.Color.BorderColor
        titleLabel.font = Constants.General.Font.InputFont
        
        detailLabel.textColor = Constants.General.Color.InputTextColor
        detailLabel.font = Constants.General.Font.InputFont
        
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
