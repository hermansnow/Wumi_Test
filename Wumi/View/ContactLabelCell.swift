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
            self.detailLabel.text = self.detail
            for button in self.actionButtons {
                guard let detail = self.detail where detail.characters.count > 0 else {
                    button.enabled = false
                    continue
                }
                
                button.enabled = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.textColor = Constants.General.Color.BorderColor
        self.titleLabel.font = Constants.General.Font.InputFont
        
        self.detailLabel.textColor = Constants.General.Color.InputTextColor
        self.detailLabel.font = Constants.General.Font.InputFont
        
        selectionStyle = .None
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.detailLabel.text = nil
        for button in self.actionButtons {
            button.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        }
    }

}
