//
//  PostTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class PostTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet weak var contentTextView: TTTAttributedLabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet private weak var timeStampLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var saveButton: FavoriteButton!
    @IBOutlet private weak var saveLabel: UILabel!
    @IBOutlet weak var replyButton: ReplyButton!
    @IBOutlet private weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    @IBOutlet weak var separator: UIView!
    
    var delegate: protocol<TTTAttributedLabelDelegate>? {
        didSet {
            self.contentTextView.delegate = self.delegate
        }
    }
    
    var showSummary: Bool {
        get {
            return self.contentTextView.numberOfLines > 0
        }
        set {
            if newValue {
                self.contentTextView.numberOfLines = 3
            }
            else {
                self.contentTextView.numberOfLines = 0
            }
        }
    }
    
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
                print(UIFont.familyNames())
                attributeContent.addAttribute(NSFontAttributeName,
                                              value: Constants.Post.Font.ListTitle,
                                              range: NSRange(location: 0, length: attributeContent.string.utf16.count))
                attributeContent.highlightString(self.highlightedString)
                self.titleLabel.attributedText = attributeContent
            }
            else {
                self.titleLabel.attributedText = nil
            }
        }
    }
    
    var content: NSAttributedString? {
        get {
            return self.contentTextView.attributedText
        }
        set {
            if let content = newValue {
                let attributeContent = PostTableViewCell.attributedText(content)
                    
                attributeContent.highlightString(self.highlightedString)
                self.contentTextView.setText(attributeContent)
            }
            else {
                self.contentTextView.setText(nil)
            }
        }
    }
    
    var highlightedString: String?
    
    var previewImageUrl: NSURL? {
        didSet {
            guard let url = self.previewImageUrl, data = NSData(contentsOfURL: url) else {
                self.previewImage = nil
                return
            }
            
            self.previewImage = UIImage(data: data)
        }
    }
    
    var previewImage: UIImage? {
        get {
            return self.imagePreview.image
        }
        set {
            self.imagePreview.image = newValue
            self.hideImageView = newValue == nil
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
        self.titleLabel.font = Constants.Post.Font.ListTitle
        self.titleLabel.textColor = Constants.General.Color.TextColor
        
        // Set up user banner
        self.authorView.detailLabel.font = Constants.Post.Font.ListUserBanner
        self.authorView.detailLabel.textColor = Constants.Post.Color.ListDetailText
        
        // Set up content text view
        self.showSummary = true
        self.contentTextView.userInteractionEnabled = true
        self.contentTextView.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.contentTextView.linkAttributes = [ NSForegroundColorAttributeName: Constants.General.Color.ThemeColor,
                                                NSFontAttributeName: Constants.Post.Font.ListContent]
        self.contentTextView.lineBreakMode = .ByWordWrapping
        
        // Set up image view
        self.imagePreview.contentMode = .ScaleAspectFit
        
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
        self.isSaved = false
    }
    
    class func fixedHeight() -> CGFloat {
        // Top margin + title label height + space + author view height + space + space + time stamp height + space + button stack height + space + separater height + bottom margin
        return 16 + 20 + 8 + 16 + 12 + 16 + 16 + 16 + 20 + 16 + 1 + 16
    }
    
    class func fixedImagePreviewHeight() -> CGFloat {
        return 80
    }
    
    class func attributedText(content: NSAttributedString) -> NSMutableAttributedString {
        let attributeContent = NSMutableAttributedString(attributedString: content)
        
        attributeContent.addAttribute(NSForegroundColorAttributeName,
                                      value: Constants.General.Color.TextColor,
                                      range: NSRange(location: 0, length: attributeContent.string.utf16.count))
        attributeContent.addAttribute(NSFontAttributeName,
                                      value: Constants.Post.Font.ListContent,
                                      range: NSRange(location: 0, length: attributeContent.string.utf16.count))
        
        return attributeContent
    }
}
