//
//  ComposePostView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class ComposePostView: UIView {
    /// Textfield for post subject.
    private lazy var subjectTextField = UITextField()
    /// Textview for post content.
    private lazy var contentTextView: PlaceholderTextView = PlaceholderTextView()
    /// Input tool bar view.
    private lazy var inputToolbar = UIView()
    /// Button to add image.
    private lazy var addImageButton = UIButton()
    /// Stack view for post view components.
    private lazy var postStackView = UIStackView()
    /// Stack view for selected images.
    private lazy var selectedImageStackView = UIStackView()
    
    // MARK: Properties
    
    /// ComposePostView delegate.
    var delegate: ComposePostViewDelegate? {
        didSet {
            self.subjectTextField.delegate = delegate
            self.contentTextView.delegate = delegate
            if let delegate = self.delegate {
                self.addImageButton.addTarget(self.delegate, action: #selector(delegate.selectImage), forControlEvents: .TouchUpInside)
            }
            for subview in self.selectedImageStackView.arrangedSubviews {
                guard let imageView = subview as? SelectedThumbnailImageView else { continue }
                
                imageView.delegate = delegate
            }
        }
    }
    /// Subject string of post.
    var subject: String {
        get {
            return self.subjectTextField.text!
        }
        set {
            self.subjectTextField.text = newValue
        }
    }
    /// Background color of subject textfield.
    var subjectBackgroundColor: UIColor? {
        get {
            return self.subjectTextField.backgroundColor
        }
        set {
            self.subjectTextField.backgroundColor = newValue
        }
    }
    /// Content string of post.
    var content: String {
        get {
            return self.contentTextView.text
        }
        set {
            self.contentTextView.text = newValue
        }
    }
    /// Maxinum length of content.
    var contentLengthLimit: Int? {
        get {
            return self.contentTextView.characterLimit
        }
        set {
            self.contentTextView.characterLimit = newValue
        }
    }
    /// Flag indicating whether enables to add image to post or not.
    var enableAddImage: Bool {
        get {
            return self.addImageButton.enabled
        }
        set {
            self.addImageButton.enabled = newValue
            self.addImageButton.hidden = !newValue
        }
    }
    /// Flag indicating whether the content text view allows the user to edit style information.
    var allowsContentEditingTextAttributes: Bool {
        get {
            return self.contentTextView.allowsEditingTextAttributes
        }
        set {
            self.contentTextView.allowsEditingTextAttributes = newValue
        }
    }
    /// Array of images attached to this post.
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
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
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
        self.addImageButton.setBackgroundImage(UIImage(named: "Add"),
                                               forState: .Normal)
        if let delegate = self.delegate {
            self.addImageButton.addTarget(self.delegate, action: #selector(delegate.selectImage), forControlEvents: .TouchUpInside)
        }
    }
    
    /**
     Private function to be called after initialization to set up its subviews's layout.
     */
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
    
    /**
     Update UI when attaching a new image into this post.
     
     - Parameters:
        - image: image attached to this post.
     */
    func insertImage(image: UIImage) {
        self.selectedImages.append(image)
        
        // Genetate image view
        let selectedImageView = SelectedThumbnailImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        selectedImageView.image = image
        selectedImageView.delegate = self.delegate
        selectedImageView.index = self.selectedImages.count - 1
        self.selectedImageStackView.insertArrangedSubview(selectedImageView, atIndex: selectedImageView.index)
    }
    
    /**
     Update UI when removing an attached images.
     
     - Parameters:
        - imageView: image view to be removed from this post.
     */
    func removeImage(imageView: SelectedThumbnailImageView) {
        guard let image = imageView.image else { return }
        
        imageView.removeFromSuperview()
        self.selectedImages.removeObject(image)
    }
    
    /**
     Update UI when removing all attached images.
     */
    func removeAllImages() {
        for subview in self.selectedImageStackView.arrangedSubviews {
            guard let selectedImageView = subview as? SelectedThumbnailImageView else { continue }
            
            selectedImageView.removeFromSuperview()
        }
        self.selectedImages.removeAll()
    }
}

// MARK: ComposePostViewDelegate delegate

@objc protocol ComposePostViewDelegate: UITextViewDelegate, UITextFieldDelegate, SelectedThumbnailImageViewDelegate {
     func selectImage()
}
