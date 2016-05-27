//
//  SelectedThumbnailImageView.swift
//  Wumi
//
//  Created by Zhe Cheng on 5/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SelectedThumbnailImageView: UIButton {
    
    private lazy var removeIcon = UIButton()
    
    // MARK: Properties
    
    var delegate: SelectedThumbnailImageViewDelegate? {
        didSet {
            // Add gestures
            print(self.delegate)
            self.setAction()
        }
    }
    
    var image: UIImage? {
        didSet {
            guard let image = self.image else { return }
            self.thumbnail = image.scaleToSize(self.bounds.size, aspectRatio: false)
        }
    }
    
    var thumbnail: UIImage? {
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
        
    }
    
    // MARK: Help functions
    
    private func setProperty() {
        self.clipsToBounds = true
        self.adjustsImageWhenHighlighted = false
        self.showsTouchWhenHighlighted = false
        self.imageView?.contentMode = .ScaleAspectFit
        
        self.removeIcon.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.removeIcon.setBackgroundImage(UIImage(named: "Checkmark"), forState: .Normal)
        self.addSubview(self.removeIcon)
        self.bringSubviewToFront(self.removeIcon)
        
        self.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    private func setAction() {
        guard let delegate = self.delegate else { return }
        
        self.addTarget(delegate, action: #selector(SelectedThumbnailImageViewDelegate.showImage(_:)), forControlEvents: .TouchUpInside)
        self.removeIcon.addTarget(self, action: #selector(self.removeIconClicked), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    
    func removeIconClicked() {
        guard let delegate = self.delegate else { return }
        
        delegate.removeImage(self)
    }
}

// MARK: SelectedThumbnailImageViewDelegate delegate

@objc protocol SelectedThumbnailImageViewDelegate {
    func removeImage(imageView: SelectedThumbnailImageView) -> Void
    func showImage(imageView: SelectedThumbnailImageView) -> Void
}
