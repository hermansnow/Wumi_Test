//
//  AvatarImageView.swift
//  Wumi
//
//  Created by Herman on 2/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class AvatarImageView: UIView {
    
    var delegate: AvatarImageDelegate?
    private var containerImageView = UIImageView()
    
    var image: UIImage? {
        get {
            return self.containerImageView.image
        }
        set {
            self.containerImageView.image = newValue
        }
    }
    
    // MARK: Initializers
    
    override func drawRect(rect: CGRect) {
        // Set container image view
        self.containerImageView.frame = rect
        self.containerImageView.contentMode = .ScaleAspectFill
        addSubview(containerImageView)
        
        // Set circular avatar image
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        
        if let delegate = self.delegate {
            // Add gestures
            let singleTapGesture = UITapGestureRecognizer(target: delegate, action: Selector("singleTap:"))
            
            self.userInteractionEnabled = true
            self.addGestureRecognizer(singleTapGesture)
        }
    }
}

@objc protocol AvatarImageDelegate {
    optional func singleTap(imageView: AvatarImageView)
}