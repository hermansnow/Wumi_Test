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
    private var containerImageView: UIImageView = UIImageView()
    
    var image: UIImage? {
        get {
            return containerImageView.image
        }
        set {
            containerImageView.image = newValue
        }
    }

    override func drawRect(rect: CGRect) {
        // Set up container image view
        containerImageView.frame = rect
        containerImageView.contentMode = .ScaleAspectFill
        addSubview(containerImageView)
        
        // Set circular avatar image
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
        
        if delegate != nil {
            // Add gestures
            let singleTap = UITapGestureRecognizer(target: delegate, action: Selector("singleTap:"))
            
            userInteractionEnabled = true
            addGestureRecognizer(singleTap)
        }
    }
}

@objc protocol AvatarImageDelegate: NSObjectProtocol {
    func singleTap(imageView: AvatarImageView);
}