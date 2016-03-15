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
        
        titleLabel.font = Constants.General.Font.InputFont
        titleLabel.textColor = Constants.General.Color.BorderColor
        
        inputTextField.borderStyle = .None
        inputTextField.font = Constants.General.Font.InputFont
        inputTextField.textColor = Constants.General.Color.InputTextColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reset() {
        titleLabel.text = nil
        inputTextField.text = nil
        inputTextField.keyboardType = .Default
        inputTextField.tag = 0
    }

}
