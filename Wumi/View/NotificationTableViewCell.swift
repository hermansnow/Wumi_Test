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
        self.contentLabel.textColor = Constants.General.Color.TextColor
        self.contentLabel.font = Constants.General.Font.InputFont
        self.timeStampLabel.textColor = Constants.Post.Color.ListDetailText
        self.timeStampLabel.font = Constants.Post.Font.ListTimeStamp
    }
    
}
