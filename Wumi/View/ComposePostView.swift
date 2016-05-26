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
    lazy var inputToolbar = UIView()
    lazy var addImageButton = UIButton()
    private lazy var postStackView = UIStackView()
    lazy var selectedImageStackView = UIStackView()
    
    // MARK: Properties
    
    var delegate: protocol<ComposePostViewDelegate, SelectedThumbnailImageViewDelegate>? {
        didSet {
            self.subjectTextField.delegate = delegate
            self.contentTextView.delegate = delegate
            for subview in self.selectedImageStackView.arrangedSubviews {
                guard let imageView = subview as? SelectedThumbnailImageView else { continue }
                
                imageView.delegate = delegate
            }
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
    
    var contentLengthLimit: Int? {
        get {
            return self.contentTextView.characterLimit
        }
        set {
            self.contentTextView.characterLimit = newValue
        }
    }
    
    var selectedImages = [UIImage]()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
        self.setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
        self.setLayout()
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
        self.postStackView.addArrangedSubview(self.subjectTextField)
        self.postStackView.addArrangedSubview(self.contentTextView)
        self.postStackView.addArrangedSubview(self.inputToolbar)
        self.postStackView.axis = .Vertical
        self.postStackView.distribution = .Fill
        self.postStackView.alignment = .Fill
        self.postStackView.spacing = 0
        self.addSubview(self.postStackView)
        
        // Add keyboard tool bar
        self.inputToolbar.addSubview(self.selectedImageStackView)
        self.selectedImageStackView.addArrangedSubview(self.addImageButton)
        self.selectedImageStackView.addArrangedSubview(UIView())
        self.selectedImageStackView.axis = .Horizontal
        self.selectedImageStackView.distribution = .Fill
        self.selectedImageStackView.alignment = .Center
        self.selectedImageStackView.spacing = 3
        self.addImageButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.addImageButton.setBackgroundImage(UIImage(named: "Add"), forState: .Normal)
        self.addImageButton.addTarget(self.delegate, action: #selector(self.delegate?.selectImage), forControlEvents: .TouchUpInside)
    }
    
    private func setLayout() {
        // Layout for subject text field
        NSLayoutConstraint(item: self.subjectTextField,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 40).active = true
        
        // Layout for post stackview
        self.postStackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        self.postStackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        self.postStackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        self.postStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        self.postStackView.translatesAutoresizingMaskIntoConstraints = false

        // Layout for selected image stackview
        self.selectedImageStackView.leftAnchor.constraintEqualToAnchor(self.inputToolbar.leftAnchor, constant: 10).active = true
        self.selectedImageStackView.rightAnchor.constraintEqualToAnchor(self.inputToolbar.rightAnchor, constant: 10).active = true
        self.selectedImageStackView.topAnchor.constraintEqualToAnchor(self.inputToolbar.topAnchor, constant: 2).active = true
        self.selectedImageStackView.bottomAnchor.constraintEqualToAnchor(self.inputToolbar.bottomAnchor, constant: 2).active = true
        self.selectedImageStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout for input tool bar
        NSLayoutConstraint(item: self.inputToolbar,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 66).active = true
    }
    
    // MARK: Actions
    
    // Add a new image 
    func insertImage(image: UIImage) {
        let selectedImageView = SelectedThumbnailImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        selectedImageView.image = image
        selectedImageView.delegate = self.delegate
        self.selectedImageStackView.insertArrangedSubview(selectedImageView, atIndex: self.selectedImageStackView.arrangedSubviews.count - 2)
        
        self.selectedImages.append(image)
    }
    
    // Remove all selected images
    func removeAllImages() {
        for subview in self.selectedImageStackView.arrangedSubviews {
            guard let selectedImageView = subview as? SelectedThumbnailImageView else { continue }
            
            selectedImageView.removeFromSuperview()
        }
        self.selectedImages.removeAll()
    }
}

// MARK: ComposePostViewDelegate delegate

@objc protocol ComposePostViewDelegate: UITextViewDelegate, UITextFieldDelegate {
     func selectImage()
}
