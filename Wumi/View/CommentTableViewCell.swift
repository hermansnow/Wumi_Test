//
//  CommentTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet weak var contentLabel: CommentTextLabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.layer.backgroundColor = Constants.General.Color.BackgroundColor.CGColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Set up user banner
        self.authorView.detailLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.authorView.detailLabel.textColor = UIColor.lightGrayColor()
        self.authorView.backgroundColor = Constants.General.Color.BackgroundColor
        
        // Set up content label
        self.contentLabel.font = UIFont(name: ".SFUIText-Regular", size: 14)
        self.contentLabel.numberOfLines = 0
        
        // Set up timestamp
        self.timeStampLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.timeStampLabel.textColor = UIColor.lightGrayColor()
    }
    
}
