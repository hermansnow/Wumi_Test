//
//  ProfileInputCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileInputCell: ProfileCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = Constants.General.Font.InputFont
        self.titleLabel.textColor = Constants.General.Color.BorderColor
        
        self.inputTextField.borderStyle = .None
        self.inputTextField.font = Constants.General.Font.InputFont
        self.inputTextField.textColor = Constants.General.Color.InputTextColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.inputTextField.text = nil
        self.inputTextField.keyboardType = .Default
        self.inputTextField.tag = 0
    }

}
