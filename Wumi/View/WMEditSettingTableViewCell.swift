//
//  WMEditSettingTableViewCell.Swift
//  Wumi
//
//  Created by Zhe Cheng on 12/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMEditSettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var setting:Setting?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.borderStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithSetting(setting:Setting?) {
        if setting != nil {
            self.setting = setting
            self.nameLabel.text = setting!.name
            self.textField.text = setting?.value
            switch setting!.type {
            case .DisplayOnly:
                self.textField.userInteractionEnabled = false
            case .Input:
                self.textField.userInteractionEnabled = true
            case .Disclosure:
                self.textField.userInteractionEnabled = false
                self.accessoryType = .DisclosureIndicator
            default: break
            }
        }
    }

}
