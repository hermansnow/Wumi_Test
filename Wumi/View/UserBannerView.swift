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
    private lazy var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    private func setProperty() {
        // Add Margin
        self.stackView.frame = self.bounds
        self.stackView.layoutMargins = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        self.stackView.layoutMarginsRelativeArrangement = true
        
        // Add subviews
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.avatarImageView)
        self.stackView.addArrangedSubview(self.detailLabel)
        self.stackView.spacing = 5
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
}
