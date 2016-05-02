//
//  ProfileInputTableCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileInputTableCell: ProfileTableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = Constants.General.Font.ProfileTitleFont
        self.titleLabel.textColor = Constants.General.Color.ProfileTitleColor
        
        self.inputTextField.borderStyle = .None
        self.inputTextField.font = Constants.General.Font.ProfileTextFont
        self.inputTextField.textColor = Constants.General.Color.InputTextColor
        
        self.reset()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Update separator
        self.separator.frame = CGRect(x: self.titleLabel.frame.origin.x,
                                      y: self.titleLabel.frame.origin.y + self.titleLabel.bounds.height + 6,
                                      width: self.titleLabel.bounds.width,
                                      height: 1.0)
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.inputTextField.text = nil
        self.inputTextField.keyboardType = .Default
        self.inputTextField.tag = 0
    }

}
