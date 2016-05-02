//
//  ProfileTableCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileTableCell: UITableViewCell {

    lazy var separator = CALayer()
    private var topBorder = CALayer()
    private var bottomBorder = CALayer()
    private var leftBorder = CALayer()
    private var rightBorder = CALayer()
    
    var enableBorder = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setProperty()
        
        self.drawBorder()
        
        layer.addSublayer(separator)
    }
    
    func setProperty() {
        self.selectionStyle = .None
        self.separator.backgroundColor = Constants.General.Color.ProfileTitleColor.CGColor
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.topBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.bottomBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.leftBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.rightBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    private func drawBorder() {
        self.topBorder.borderWidth = CGFloat(4.0)
        self.bottomBorder.borderWidth = CGFloat(4.0)
        self.leftBorder.borderWidth = CGFloat(8.0)
        self.rightBorder.borderWidth = CGFloat(8.0)
        
        self.layer.addSublayer(self.topBorder)
        self.layer.addSublayer(self.bottomBorder)
        self.layer.addSublayer(self.leftBorder)
        self.layer.addSublayer(self.rightBorder)
        self.layer.masksToBounds = true
    }
    
    override func drawRect(rect: CGRect) {
        if enableBorder {
            self.topBorder.frame = CGRect(x:0, y:0, width:rect.size.width, height:self.topBorder.borderWidth)
            self.bottomBorder.frame = CGRect(x:0, y:rect.size.height - self.bottomBorder.borderWidth, width:rect.size.width, height:self.bottomBorder.borderWidth)
            self.leftBorder.frame = CGRect(x: 0, y: 0, width: self.leftBorder.borderWidth, height: rect.size.height)
            self.rightBorder.frame = CGRect(x: rect.size.width - self.rightBorder.borderWidth, y: 0, width: self.rightBorder.borderWidth, height: rect.size.height)
            
        }
        else {
            self.topBorder.frame = CGRectZero
            self.bottomBorder.frame = CGRectZero
            self.leftBorder.frame = CGRectZero
            self.rightBorder.frame = CGRectZero
        }
    }
}