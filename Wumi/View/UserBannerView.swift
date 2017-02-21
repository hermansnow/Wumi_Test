//
//  UserBannerView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class UserBannerView: UIView {

    lazy var avatarImageView: AvatarImageView = AvatarImageView()
    lazy var detailLabel = UILabel()
    private lazy var placeHolder = UIView()
    private lazy var stackView = UIStackView()
    
    var userObjectId: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    private func setProperty() {
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        
        // Add Margin
        self.stackView.frame = self.bounds
        
        // Add subviews
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.avatarImageView)
        self.stackView.addArrangedSubview(self.detailLabel)
        self.stackView.addArrangedSubview(self.placeHolder)
        self.stackView.spacing = 8
        NSLayoutConstraint(item: self.avatarImageView,
                      attribute: .Height,
                      relatedBy: .Equal,
                         toItem: self.avatarImageView,
                      attribute: .Width,
                     multiplier: 1,
                       constant: 0).active = true
    }
    
    override func drawRect(rect: CGRect) {
        // Add sub stackview
        self.stackView.frame = rect
    }
    
    func reset() {
        self.detailLabel.text = nil
    }
    
    // Override hitTest function to disable user interaction with the placeHolder
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self.placeHolder {
            return nil
        }
        else {
            return hitView
        }
    }
}
