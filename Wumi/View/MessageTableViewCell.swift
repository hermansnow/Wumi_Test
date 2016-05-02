//
//  MessageTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var authorView: UserBannerView!
    @IBOutlet private weak var contentTextView: PostTextView!
    @IBOutlet private weak var timeStampLabel: UILabel!
    @IBOutlet weak var saveButton: FavoriteButton!
    @IBOutlet private weak var saveLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet private weak var replyLabel: UILabel!
    @IBOutlet weak var repliesButton: UIButton!
    
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
    
    var highlightString: String? {
        didSet {
            // Check title
            self.highlightString(&self.title)
            
            // Check content
            self.highlightString(&self.content)
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
        self.titleLabel.font = UIFont(name: ".SFUIText-Bold", size: 16)
        
        // Set up user banner
        self.authorView.detailLabel.font = UIFont(name: ".SFUIText-Medium", size: 14)
        self.authorView.detailLabel.textColor = UIColor.lightGrayColor()
        self.authorView.backgroundColor = Constants.General.Color.BackgroundColor
        
        // Set up content label
        self.showSummary = true
        self.contentTextView.font = UIFont(name: ".SFUIText-Regular", size: 14)
        self.contentTextView.scrollEnabled = false
        self.contentTextView.editable = false
        self.contentTextView.selectable = true
        self.contentTextView.dataDetectorTypes = .All
        
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
    
    func reset() {
        self.title = nil
        self.content = nil
        self.timeStamp = nil
        self.authorView.reset()
        //self.saveButton.delegate = nil
        //self.saveButton.selected = false
    }
    
    func highlightString(inout attributeString: NSMutableAttributedString?) {
        guard let keywords = self.highlightString where keywords.characters.count > 0, let attribute = attributeString else { return }
        
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
