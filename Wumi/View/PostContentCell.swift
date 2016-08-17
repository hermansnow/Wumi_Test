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
    @IBOutlet weak var replyButton: ReplyButton!
    @IBOutlet private weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    
    // MARK: Properties
    
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            if let title = newValue {
                let attributeContent = NSMutableAttributedString(string: title)
                
                attributeContent.addAttribute(NSForegroundColorAttributeName,
                                              value: Constants.General.Color.TextColor,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                attributeContent.addAttribute(NSFontAttributeName,
                                              value: Constants.Post.Font.ListTitle!,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                self.titleLabel.attributedText = attributeContent
            }
            else {
                self.titleLabel.attributedText = nil
            }
        }
    }
    
    var content: String? {
        get {
            return self.contentTextView.text
        }
        set {
            if let content = newValue {
                let attributeContent = NSMutableAttributedString(string: content)
                
                attributeContent.addAttribute(NSForegroundColorAttributeName,
                                              value: Constants.General.Color.TextColor,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                attributeContent.addAttribute(NSFontAttributeName,
                                              value: Constants.Post.Font.ListContent!,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                self.contentTextView.attributedText = attributeContent
                
                self.contentTextView.replaceLink()
            }
            else {
                self.contentTextView.attributedText = nil
            }
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
    
    var isSaved = false {
        didSet {
            self.saveButton.selected = self.isSaved
            if self.isSaved {
                self.saveLabel.text = "Saved"
            }
            else {
                self.saveLabel.text = "Save"
            }
        }
    }
    
    var delegate: protocol<UITextViewDelegate, KIImagePagerDelegate, KIImagePagerDataSource, FavoriteButtonDelegate, ReplyButtonDelegate>? {
        didSet {
            self.contentTextView.delegate = self.delegate
            self.imagePager.dataSource = self.delegate
            self.imagePager.delegate = self.delegate
            self.saveButton.delegate = self.delegate
            self.replyButton.delegate = self.delegate
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
        self.titleLabel.font = Constants.Post.Font.ListTitle
        self.titleLabel.textColor = Constants.General.Color.TextColor
        
        // Set up user banner
        self.authorView.detailLabel.font = Constants.Post.Font.ListUserBanner
        self.authorView.detailLabel.textColor = Constants.Post.Color.ListDetailText
        
        // Set up content label
        self.contentTextView.textContainer.maximumNumberOfLines = 0
        self.contentTextView.selfUserInteractionEnabled = true
        
        // Set up timestamp
        self.timeStampLabel.font = Constants.Post.Font.ListTimeStamp
        self.timeStampLabel.textColor = Constants.Post.Color.ListDetailText
        
        // Set up buttons
        self.saveLabel.font = Constants.Post.Font.ListButton
        self.saveLabel.textColor = Constants.General.Color.ThemeColor
        self.replyLabel.font = Constants.Post.Font.ListButton
        self.replyLabel.textColor = Constants.General.Color.ThemeColor
        self.repliesButton.titleLabel?.font = Constants.Post.Font.ListReply
        self.repliesButton.titleLabel?.textColor = Constants.General.Color.ThemeColor
    }
    
    // MARK: Help functions
    
    private func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
    }
    
    func reset() {
        self.content = nil
        self.timeStamp = nil
        self.authorView.reset()
        self.hideImageView = true
        self.isSaved = false
    }
}
