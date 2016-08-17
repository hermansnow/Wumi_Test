//
//  NotificationTableViewCell.swift
//  Wumi
//
//  Created by Guang Han on 4/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import HexColors

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentLabel.text = nil
        self.contentLabel.numberOfLines = 0
        self.timeStampLabel.text = nil
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.backgroundColor = UIColor.clearColor()
        self.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)
        self.contentLabel.textColor = UIColor.init(hexString: "#333435")
        self.contentLabel.font = UIFont(name: ".SFUIText-Light", size: 16)
        self.timeStampLabel.textColor = UIColor.init(hexString: "#A2A2A2")
        self.timeStampLabel.font = UIFont(name: ".SFUIText-Regular", size: 14)
    }
    
}
