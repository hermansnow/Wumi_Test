//
//  ProfileLabelTableCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileLabelTableCell: ProfileTableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var actionButtonStack: UIStackView!
    var actionButtons = [UIButton]()
    
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
        
        self.titleLabel.textColor = Constants.General.Color.ProfileTitleColor
        self.titleLabel.font = Constants.General.Font.ProfileTitleFont
        
        self.detailLabel.textColor = Constants.General.Color.InputTextColor
        self.detailLabel.font = Constants.General.Font.ProfileTextFont
        
        self.actionButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.reset()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Update separator
        self.separator.frame = CGRect(x: self.titleLabel.frame.origin.x,
                                      y: self.titleLabel.frame.origin.y + self.titleLabel.bounds.height + 5,
                                      width: self.titleLabel.bounds.width,
                                      height: 1.0)
        for button in self.actionButtons {
            NSLayoutConstraint(item: button,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: button,
                attribute: .Width,
                multiplier: 1,
                constant: 0).active = true
            self.addSubview(button)
            self.actionButtonStack.addArrangedSubview(button)
            
            button.enabled = self.detail != nil && self.detail!.characters.count > 0
        }
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.detailLabel.text = nil
        for button in self.actionButtons {
            button.removeFromSuperview()
            self.actionButtonStack.removeArrangedSubview(button)
        }
        self.actionButtons.removeAll()
    }

}
