//
//  PlaceholderTextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    /// Label for placeholder.
    private var placeholderLabel: UILabel = UILabel()
    /// Array of layout constraints for placeholder label.
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    /// Maxinum number of characters for this text view.
    var characterLimit: Int?
    /// Placeholder string of this text view.
    var placeholder: String? {
        didSet {
            self.placeholderLabel.text = self.placeholder
        }
    }
    /// Content text of this text view.
    override var text: String! {
        didSet {
            self.textDidChange()
        }
    }
    /// Edge inset for the container of text.
    override var textContainerInset: UIEdgeInsets {
        didSet {
            self.updateConstraintsForPlaceholderLabel()
        }
    }
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.font = Constants.General.Font.InputFont
        self.dataDetectorTypes = .All
        
        // Set up placeholder label
        self.placeholderLabel.text = self.placeholder
        self.placeholderLabel.textColor = Constants.Post.Color.Placeholder
        self.placeholderLabel.font = Constants.General.Font.InputFont
        self.placeholderLabel.numberOfLines = 0
        self.placeholderLabel.backgroundColor = UIColor.clearColor()
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.placeholderLabel)
        self.updateConstraintsForPlaceholderLabel()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.textDidChange),
                                                         name: UITextViewTextDidChangeNotification,
                                                         object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    // MARK: Helper functions
    
    /**
     Action when text view's content is changed.
     */
    func textDidChange() {
        self.placeholderLabel.hidden = !self.text.isEmpty
    }
    
    /**
     Update placeholder label's contraint.
     */
    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(\(self.textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
                                                                            options: [],
                                                                            metrics: nil,
                                                                            views: ["placeholder": self.placeholderLabel])
        newConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(\(self.textContainerInset.top))-[placeholder]",
                                                                         options: [],
                                                                         metrics: nil,
                                                                         views: ["placeholder": self.placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
            item: self.placeholderLabel,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Width,
            multiplier: 1.0,
            constant: -(self.textContainerInset.left + self.textContainerInset.right + self.textContainer.lineFragmentPadding * 2.0)
        ))
        
        self.removeConstraints(placeholderLabelConstraints)
        self.addConstraints(newConstraints)
        self.placeholderLabelConstraints = newConstraints
    }
    
    /**
     Remaining number of characters allowed to be added in.
     
     - Returns:
        Number of characters allowed to be added.
     */
    func checkRemainingCharacters() -> Int? {
        if let limit = self.characterLimit {
            return limit - self.text.characters.count
        }
        else {
            return nil
        }
    }
}
