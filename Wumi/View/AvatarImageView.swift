//
//  AvatarImageView.swift
//  Wumi
//
//  Created by Herman on 2/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class AvatarImageView: UIView {
    private lazy var containerImageView = UIImageView()
    
    var delegate: AvatarImageDelegate? {
        didSet {
            if let delegate = self.delegate {
                // Add gestures
                let singleTapGesture = UITapGestureRecognizer(target: delegate, action: #selector(AvatarImageDelegate.singleTap(_:)))
                
                self.userInteractionEnabled = true
                self.addGestureRecognizer(singleTapGesture)
            }
        }
    }
    
    var image: UIImage? {
        get {
            return self.containerImageView.image
        }
        set {
            self.containerImageView.image = newValue
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
    
    private func setProperty() {
        // Add container image view
        self.containerImageView.contentMode = .ScaleAspectFill
        addSubview(containerImageView)
        
        // Set circular avatar image
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        self.containerImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        self.layer.cornerRadius = self.frame.size.height / 2
    }
}

@objc protocol AvatarImageDelegate {
    optional func singleTap(imageView: AvatarImageView)
}