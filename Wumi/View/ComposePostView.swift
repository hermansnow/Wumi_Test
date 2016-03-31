//
//  ComposePostView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ComposePostView: UIView {
    
    lazy var subjectTextField = UITextField()
    lazy var contentTextView: PostTextView = PostTextView()
    private lazy var stackView = UIStackView()
    
    var delegate: protocol<UITextViewDelegate, UITextFieldDelegate>? {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
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
    }
    
    override func drawRect(rect: CGRect) {
        // Add sub stackview
        self.stackView.frame = rect
    }
}
