//
//  RichTextPostView.swift
//  Wumi
//
//  Created by Zhe Cheng on 5/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class RichTextPostView: UIView {

    lazy var subjectTextField = UITextField()
    lazy var contentTextView: PlaceholderTextView = PlaceholderTextView()
    lazy var inputToolbar = UIToolbar()
    private lazy var stackView = UIStackView()
    
    // MARK: Properties
    
    var delegate: ComposePostViewDelegate? {
        didSet {
            self.subjectTextField.delegate = delegate
            self.contentTextView.delegate = delegate
        }
    }
    
    var title: String {
        get {
            return self.subjectTextField.text!
        }
        set {
            self.subjectTextField.text = newValue
        }
    }
    
    var content: String {
        get {
            return self.contentTextView.text
        }
        set {
            self.contentTextView.text = newValue
        }
    }
    
    var attributedContent: NSAttributedString {
        get {
            return self.contentTextView.attributedText
        }
        set {
            self.contentTextView.attributedText = newValue
        }
    }
    
    var contentLengthLimit: Int? {
        get {
            return self.contentTextView.characterLimit
        }
        set {
            self.contentTextView.characterLimit = newValue
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    override func drawRect(rect: CGRect) {
        self.stackView.frame = rect
    }
    
    // MARK: Help functions
    
    private func setProperty() {
        // Initialize subject text field
        self.subjectTextField.placeholder = "Add a new subject"
        self.subjectTextField.backgroundColor = Constants.General.Color.BackgroundColor
        self.subjectTextField.leftSpacing = 5
        
        // Initialize post text view
        self.contentTextView.placeholder = "Write a message"
        
        // Add subviews
        self.stackView.frame = self.bounds
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.subjectTextField)
        self.stackView.addArrangedSubview(self.contentTextView)
        self.stackView.axis = .Vertical
        self.stackView.distribution = .Fill
        self.stackView.alignment = .Fill
        self.stackView.spacing = 0
        NSLayoutConstraint(item: self.subjectTextField,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 40).active = true
        
        // Add keyboard tool
        self.inputToolbar.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 60)
        self.inputToolbar.barStyle = .BlackTranslucent
        let doneButton = UIBarButtonItem(image: UIImage(named: "Camera_Selected"), style: .Plain, target: self.delegate, action: #selector(self.delegate?.selectImage))
        self.inputToolbar.setItems([doneButton], animated: false)
        self.inputToolbar.sizeToFit()
        self.contentTextView.inputAccessoryView = inputToolbar
    }
    
    // MARK: Actions
    
    func insertImage(image: UIImage) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageAttributedStr = NSAttributedString(attachment: imageAttachment)
        let text = NSMutableAttributedString(attributedString: self.contentTextView.attributedText)
        text.appendAttributedString(imageAttributedStr)
        self.contentTextView.attributedText = text
    }
}

// MARK: RichTextPostViewDelegate delegate

@objc protocol RichTextPostViewDelegate: UITextViewDelegate, UITextFieldDelegate {
    func selectImage()
}
