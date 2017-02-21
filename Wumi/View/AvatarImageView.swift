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
    
    /// Avatar image.
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
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        
        // Add container image view
        self.containerImageView.contentMode = .ScaleAspectFill
        self.containerImageView.backgroundColor = UIColor.clearColor()
        self.containerImageView.opaque = false
        addSubview(containerImageView)
        
        // Set circular avatar image
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        self.containerImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    
    /**
     Show an image with name initial as avatar.
     
     - Parameters:
        - name: name string to be displayed.
     */
    func showNameAvatar(name: String) {
        let initial = name.initials()
        let fontSize: CGFloat = self.frame.size.height * 0.35
        
        self.containerImageView.image = self.imageSnapshot(fromText: initial,
                                                           backgroundColor: Constants.General.Color.ThemeColor,
                                                           textAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(fontSize),
                                                                            NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Cache avatar image
        if let image = self.containerImageView.image {
            DataManager.sharedDataManager.imageCache.storeImage(image, forKey: "avatarThumbnail_\(initial)")
        }
    }
    
    /**
     Generate an image with string in the avatar view.
     
     - Parameters:
        - fromText: text string to be used to generate the image.
        - backgroundColor: background color of image.
        - textAttribute: attributes of text string.
     
     - Returns:
        New image or nil if failed.
     */
    private func imageSnapshot(fromText text:String, backgroundColor:UIColor, textAttributes: [String: AnyObject]) -> UIImage? {
        let scale = UIScreen.mainScreen().scale
        var size = self.bounds.size
        
        if self.containerImageView.contentMode == .ScaleToFill ||
            self.containerImageView.contentMode == .ScaleAspectFill ||
            self.containerImageView.contentMode == .ScaleAspectFit ||
            self.containerImageView.contentMode == .Redraw {
            
            size.width = CGFloat(floorf(Float(size.width * scale)) / Float(scale))
            size.height = CGFloat(floorf(Float(size.height * scale)) / Float(scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Fill background of context
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
        // Draw text in the context
        let myString: NSString = text as NSString
        let textSize: CGSize = myString.sizeWithAttributes(textAttributes)
        let bounds = self.bounds
        
        myString.drawInRect(CGRect(x: bounds.size.width/2 - textSize.width / 2,
                                   y: bounds.size.height / 2 - textSize.height / 2,
                                   width: textSize.width,
                                   height: textSize.height),
                            withAttributes: textAttributes)
        
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        return snapshot
    }
}

@objc protocol AvatarImageDelegate {
    optional func singleTap(imageView: AvatarImageView)
}
