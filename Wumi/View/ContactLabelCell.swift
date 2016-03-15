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
    
    var detail: String? {
        didSet {
            detailLabel.text = detail
            for button in actionButtons {
                if detail != nil && detail!.characters.count > 0 {
                    button.enabled = true
                }
                else {
                    button.enabled = false
                }

            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = Constants.General.Color.BorderColor
        titleLabel.font = Constants.General.Font.InputFont
        
        detailLabel.textColor = Constants.General.Color.InputTextColor
        detailLabel.font = Constants.General.Font.InputFont
        
        selectionStyle = .None
    }
    
    func reset() {
        titleLabel.text = nil
        detailLabel.text = nil
        for button in actionButtons {
            button.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        }
    }

}
