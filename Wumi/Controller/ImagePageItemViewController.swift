//
//  ImagePageItemViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImagePageItemViewController: UIViewController {
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set property
        self.view.backgroundColor = UIColor.blackColor()
        
        // Add subview
        self.addSubviews()
        
        // Set image view property
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = self.image
        
        // Add gestures
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapImage(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    private func addSubviews() {
        self.view.addSubview(self.imageView)
        self.imageView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.imageView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        self.imageView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.imageView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func tapImage(gesture: UIGestureRecognizer) {
        if let pageVC = self.parentViewController as? UIPageViewController,
            imageFullScreenVC = pageVC.parentViewController as? ImageFullScreenViewController {
                imageFullScreenVC.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
