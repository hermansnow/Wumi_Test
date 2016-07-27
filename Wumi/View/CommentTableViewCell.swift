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
    @IBOutlet weak var separator: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    private func setProperty() {
        self.layer.borderColor = Constants.General.Color.LightBackgroundColor.CGColor
        self.layer.backgroundColor = Constants.General.Color.LightBackgroundColor.CGColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up user banner
        self.authorView.detailLabel.font = Constants.Post.Font.ListUserBanner
        self.authorView.detailLabel.textColor = Constants.Post.Color.ListDetailText
        self.authorView.backgroundColor = Constants.General.Color.LightBackgroundColor
        
        // Set up content label
        self.contentLabel.numberOfLines = 0
        
        // Set up timestamp
        self.timeStampLabel.font = Constants.Post.Font.ListTimeStamp
        self.timeStampLabel.textColor = Constants.Post.Color.ListDetailText
        
        // Set up separator
        self.separator.backgroundColor = Constants.General.Color.BackgroundColor
    }
    
    func reset() {
        self.authorView.reset()
        self.contentLabel.text = nil
        self.timeStampLabel.text = nil
    }
}
