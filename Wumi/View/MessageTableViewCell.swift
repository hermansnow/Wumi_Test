//
//  MessageTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Set up title label
        self.titleLabel.font = UIFont(name: ".SFUIText-Bold", size: 16)
        
        // Set up user banner
        self.authorView.detailLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.authorView.detailLabel.textColor = UIColor.lightGrayColor()
        
        // Set up content label
        self.contentLabel.numberOfLines = 0
        self.contentLabel.font = UIFont(name: ".SFUIText-Regular", size: 14)
        
        // Set up timestamp
        self.timeStampLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.timeStampLabel.textColor = UIColor.lightGrayColor()
        
        // Set up buttons
        self.saveLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.saveLabel.textColor = Constants.General.Color.ThemeColor
        self.replyLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.replyLabel.textColor = Constants.General.Color.ThemeColor
        self.repliesButton.titleLabel?.font = UIFont(name: ".SFUIText-Medium", size: 14)!
        self.repliesButton.titleLabel?.textColor = Constants.General.Color.ThemeColor
    }
    
}
