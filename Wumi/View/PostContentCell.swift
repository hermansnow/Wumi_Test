//
//  PostContentCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 5/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import KIImagePager

class PostContentCell: UITableViewCell {
    
    @IBOutlet weak var imagePager: KIImagePager!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet weak var contentTextView: PostContentTextView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var saveButton: FavoriteButton!
    @IBOutlet private weak var saveLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet private weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    
    // MARK: Properties
    
    var title: NSMutableAttributedString? {
        get {
            guard let attributedTitle = self.titleLabel.attributedText else { return nil }
            
            return NSMutableAttributedString(attributedString: attributedTitle)
        }
        set {
            self.titleLabel.attributedText = newValue
        }
    }
    
    var content: NSMutableAttributedString? {
        get {
            guard let attributedContent = self.contentTextView.attributedText else { return nil }
            
            return NSMutableAttributedString(attributedString: attributedContent)
        }
        set {
            self.contentTextView.attributedText = newValue
        }
    }
    
    var timeStamp: String? {
        get {
            return self.timeStampLabel.text
        }
        set {
            self.timeStampLabel.text = newValue
        }
    }
    
    var hideImageView = true {
        didSet {
            self.imagePager.hidden = self.hideImageView
        }
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up image pager
        self.imagePager.imageCounterDisabled = true
        self.imagePager.hidePageControlForSinglePages = true
        self.imagePager.slideshowTimeInterval = 2
        self.imagePager.bounces = false
        self.imagePager.tintColor = Constants.General.Color.ThemeColor
        
        // Set up title label
        self.titleLabel.font = UIFont(name: ".SFUIText-Bold", size: 16)
        
        // Set up user banner
        self.authorView.detailLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.authorView.detailLabel.textColor = UIColor.lightGrayColor()
        self.authorView.backgroundColor = Constants.General.Color.BackgroundColor
        
        // Set up content label
        self.contentTextView.font = UIFont(name: ".SFUIText-Regular", size: 14)
        self.contentTextView.scrollEnabled = false
        self.contentTextView.editable = false
        self.contentTextView.selectable = true
        self.contentTextView.dataDetectorTypes = .All
        self.contentTextView.textContainer.maximumNumberOfLines = 0
        self.contentTextView.selfUserInteractionEnabled = true
        
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
    
    // MARK: Help functions
    
    func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
    }
}
