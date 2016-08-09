//
//  ProfileInputSwitchTableCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileInputSwitchTableCell: ProfileTableCell {

    @IBOutlet weak var titleStack: UIStackView!
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
        
        self.titleLabel.font = Constants.General.Font.ProfileTitleFont
        self.titleLabel.textColor = Constants.General.Color.ProfileTitleColor
        
        self.statusLabel.font = Constants.General.Font.ProfileTitleFont
        self.statusLabel.textColor = Constants.General.Color.ProfileTitleColor
        
        self.inputTextField.borderStyle = .None
        self.inputTextField.font = Constants.General.Font.ProfileTextFont
        self.inputTextField.textColor = Constants.General.Color.TextColor
        
        self.statusSwitch.layer.cornerRadius = 16
        self.statusSwitch.onTintColor = Constants.General.Color.ThemeColor
        self.statusSwitch.backgroundColor = Constants.General.Color.BackgroundColor
        self.statusSwitch.transform = CGAffineTransformMakeScale(24.0 / 31.0, 24.0 / 31.0)
        
        self.reset()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Update separator
        self.separator.frame = CGRect(x: self.titleStack.frame.origin.x,
                                      y: self.titleStack.frame.origin.y + self.titleStack.bounds.height + 6,
                                      width: self.titleStack.bounds.width,
                                      height: 1.0)
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
