//
//  ProfileInputSwitchCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileInputSwitchCell: ProfileCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusSwitch: SettingSwitch!
    
    var showPublic = true {
        didSet {
            statusSwitch.on = showPublic
            statusLabel.text = showPublic ? "Public" : "Private"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = Constants.General.Font.InputFont
        titleLabel.textColor = Constants.General.Color.BorderColor
        
        statusLabel.font = Constants.General.Font.InputFont
        statusLabel.textColor = Constants.General.Color.BorderColor
        
        inputTextField.borderStyle = .None
        inputTextField.font = Constants.General.Font.InputFont
        inputTextField.textColor = Constants.General.Color.InputTextColor
    }
    
    func reset() {
        titleLabel.text = nil
        inputTextField.text = nil
        inputTextField.keyboardType = .Default
        inputTextField.tag = 0
        showPublic = true
        statusSwitch.removeTarget(nil, action: nil, forControlEvents: .ValueChanged)
    }

}
