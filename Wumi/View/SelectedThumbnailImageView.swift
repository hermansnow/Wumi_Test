//
//  SelectedThumbnailImageView.swift
//  Wumi
//
//  Created by Zhe Cheng on 5/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SelectedThumbnailImageView: UIButton {
    // MARK: Properties
    
    /// Icon for removing this selected image view.
    private lazy var removeIcon = UIButton()
    /// SelectedThumbnailImageView delegate.
    var delegate: SelectedThumbnailImageViewDelegate?
    /// Remove icon's height
    private var iconHeight: CGFloat = 16
    /// Original content image for this selected thumbnail view.
    var image: UIImage? {
        didSet {
            if let image = self.image {
                self.thumbnailImage = image.scaleToSize(self.bounds.size, aspectRatio: false)
            }
            else {
                self.thumbnailImage = nil
            }
        }
    }
    /// Thumbnail image resized from original image for this thumbanil view.
    private var thumbnailImage: UIImage? {
        get {
            return self.imageForState(.Normal)
        }
        set {
            self.setImage(newValue, forState: .Normal)
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
        self.setAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
        self.setAction()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.clipsToBounds = true
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
        self.imageView?.contentMode = .ScaleAspectFit
        
        // Add remove icon
        self.removeIcon.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.iconHeight,
                                       height: self.iconHeight)
        self.removeIcon.setBackgroundImage(UIImage(named: Constants.General.ImageName.Remove),
                                           forState: .Normal)
        self.addSubview(self.removeIcon)
        self.bringSubviewToFront(self.removeIcon)
        
        self.imageEdgeInsets = UIEdgeInsets(top: self.iconHeight / 2,
                                            left: self.iconHeight / 2,
                                            bottom: self.iconHeight  / 2,
                                            right: self.iconHeight / 2)
    }
    
    /**
     Private function to be called after initialization to set up its action.
     */
    private func setAction() {
        // Add action to show image when tap
        self.addTarget(self, action: #selector(self.tapped), forControlEvents: .TouchUpInside)
        // Add action to remove image when click remove icon.
        self.removeIcon.addTarget(self, action: #selector(self.removeIconClicked), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    
    /**
     Action when remove icon clicked.
     */
    func removeIconClicked() {
        guard let delegate = self.delegate else { return }
        
        delegate.removeImage(self)
    }
    
    /**
     Action when view is tapped.
     */
    func tapped() {
        guard let delegate = self.delegate else { return }
        
        delegate.showImage(self)
    }
}

// MARK: SelectedThumbnailImageViewDelegate delegate

@objc protocol SelectedThumbnailImageViewDelegate {
    func removeImage(imageView: SelectedThumbnailImageView) -> Void
    func showImage(imageView: SelectedThumbnailImageView) -> Void
}
