//
//  PostTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet weak var contentTextView: PostContentTextView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet private weak var timeStampLabel: UILabel!
    @IBOutlet weak var saveButton: FavoriteButton!
    @IBOutlet private weak var saveLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet private weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    @IBOutlet weak var separator: UIView!
    
    var showSummary: Bool {
        get {
            return self.contentTextView.textContainer.maximumNumberOfLines > 0
        }
        set {
            if newValue {
                self.contentTextView.textContainer.maximumNumberOfLines = 3
                self.contentTextView.selfUserInteractionEnabled = false
            }
            else {
                self.contentTextView.textContainer.maximumNumberOfLines = 0
                self.contentTextView.selfUserInteractionEnabled = true
            }
        }
    }
    
    var title: NSMutableAttributedString? {
        get {
            guard let attributedTitle = self.titleLabel.attributedText else { return nil }
            
            return NSMutableAttributedString(attributedString: attributedTitle)
        }
        set {
            if let attributeContent = newValue {
                attributeContent.addAttribute(NSForegroundColorAttributeName,
                                              value: Constants.General.Color.TextColor,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                attributeContent.addAttribute(NSFontAttributeName,
                                              value: Constants.Post.Font.ListTitle!,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                self.highlightString(attributeContent)
                self.titleLabel.attributedText = attributeContent
            }
            else {
                self.titleLabel.attributedText = newValue
            }
        }
    }
    
    var content: NSMutableAttributedString? {
        get {
            guard let attributedContent = self.contentTextView.attributedText else { return nil }
        
            return NSMutableAttributedString(attributedString: attributedContent)
        }
        set {
            if let attributeContent = newValue {
                attributeContent.addAttribute(NSForegroundColorAttributeName,
                                              value: Constants.General.Color.TextColor,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                attributeContent.addAttribute(NSFontAttributeName,
                                              value: Constants.Post.Font.ListContent!,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                self.highlightString(attributeContent)
                self.contentTextView.attributedText = attributeContent
            }
            else {
                self.contentTextView.attributedText = newValue
            }
        }
    }
    
    var highlightedString: String?
    
    var previewImage: UIImage? {
        get {
            return self.imagePreview.image
        }
        set {
            self.imagePreview.image = newValue
            if newValue == nil {
                self.hideImageView = true
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
            self.imagePreview.hidden = self.hideImageView
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.layer.borderColor = Constants.General.Color.BackgroundColor.CGColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        // Set up title label
        self.titleLabel.font = Constants.Post.Font.ListTitle
        self.titleLabel.textColor = Constants.General.Color.TextColor
        
        // Set up user banner
        self.authorView.detailLabel.font = Constants.Post.Font.ListUserBanner
        self.authorView.detailLabel.textColor = Constants.Post.Color.ListUserBanner
        
        // Set up content text view
        self.showSummary = true
        self.contentTextView.scrollEnabled = false
        self.contentTextView.dataDetectorTypes = .All
        
        // Set up image view
        self.imagePreview.contentMode = .ScaleAspectFit
        
        // Set up timestamp
        self.timeStampLabel.font = Constants.Post.Font.ListTimeStamp
        self.timeStampLabel.textColor = Constants.Post.Color.ListTimeStamp
        
        // Set up buttons
        self.saveLabel.font = Constants.Post.Font.ListButton
        self.saveLabel.textColor = Constants.General.Color.ThemeColor
        self.replyLabel.font = Constants.Post.Font.ListButton
        self.replyLabel.textColor = Constants.General.Color.ThemeColor
        self.repliesButton.titleLabel?.font = Constants.Post.Font.ListReply
        self.repliesButton.titleLabel?.textColor = Constants.General.Color.ThemeColor
        
        // Set up separator
        self.separator.backgroundColor = Constants.General.Color.BackgroundColor
    }
    
    func reset() {
        self.title = nil
        self.content = nil
        self.highlightedString = nil
        self.imagePreview.image = nil
        self.timeStamp = nil
        self.authorView.reset()
        self.hideImageView = true
    }
    
    func highlightString(attributeString: NSMutableAttributedString?) {
        guard let keywords = self.highlightedString where keywords.characters.count > 0, let attribute = attributeString else { return }
        
        do {
            let regex = try NSRegularExpression(pattern: keywords, options: .CaseInsensitive)
            
            for match in regex.matchesInString(attribute.string, options: [], range: NSRange(location: 0, length: attribute.string.utf16.count)) as [NSTextCheckingResult] {
                attribute.addAttribute(NSForegroundColorAttributeName, value: Constants.General.Color.ThemeColor, range: match.range)
            }
        } catch {
            print("Failed in creating NSRegularExpression for string matching")
        }
    }
}
