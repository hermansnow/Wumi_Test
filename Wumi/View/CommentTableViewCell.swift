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
    @IBOutlet weak var contentTextView: CommentTextView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
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
                self.contentTextView.attributedText = attributeContent
            }
            else {
                self.contentTextView.attributedText = newValue
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
    
    var delegate: protocol<UITextViewDelegate>? {
        didSet {
            self.contentTextView.delegate = self.delegate
        }
    }
    
    // MARK: Initializers
    
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
        
        // Set up content text view
        self.contentTextView.font = Constants.Post.Font.ListContent
        self.contentTextView.textColor = Constants.General.Color.TextColor
        self.contentTextView.backgroundColor = Constants.General.Color.LightBackgroundColor
        
        // Set up timestamp
        self.timeStampLabel.font = Constants.Post.Font.ListTimeStamp
        self.timeStampLabel.textColor = Constants.Post.Color.ListDetailText
        
        // Set up separator
        self.separator.backgroundColor = Constants.General.Color.BackgroundColor
    }
    
    func reset() {
        self.authorView.reset()
        self.content = nil
        self.timeStamp = nil
    }
}
