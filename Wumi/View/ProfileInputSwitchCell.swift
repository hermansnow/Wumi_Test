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
            self.statusSwitch.on = self.showPublic
            self.statusLabel.text = self.showPublic ? "Public" : "Private"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = Constants.General.Font.InputFont
        self.titleLabel.textColor = Constants.General.Color.BorderColor
        
        self.statusLabel.font = Constants.General.Font.InputFont
        self.statusLabel.textColor = Constants.General.Color.BorderColor
        
        self.inputTextField.borderStyle = .None
        self.inputTextField.font = Constants.General.Font.InputFont
        self.inputTextField.textColor = Constants.General.Color.InputTextColor
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.inputTextField.text = nil
        self.inputTextField.keyboardType = .Default
        self.inputTextField.tag = 0
        self.showPublic = true
        self.statusSwitch.removeTarget(nil, action: nil, forControlEvents: .ValueChanged)
    }

}
