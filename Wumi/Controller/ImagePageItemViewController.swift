//
//  ImagePageItemViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImagePageItemViewController: UIViewController {
    /// View to show an image.
    private var imageView = UIImageView()
    /// Image to be displahed on this page.
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set property
        self.view.backgroundColor = UIColor.blackColor()
        
        // Add components
        self.addImageView()
        
        // Add gestures
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(self.tapImage))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: UI functions
    
    /**
     Add image view to this page item view controller.
     */
    private func addImageView() {
        // Add image view with contraints
        self.view.addSubview(self.imageView)
        self.imageView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.imageView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        self.imageView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.imageView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set image view property
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = self.image
    }
    
    // MARK: Action
    
    /**
     Action when tapping the image view.
     */
    func tapImage() {
        if let pageVC = self.parentViewController as? UIPageViewController,
            imageFullScreenVC = pageVC.parentViewController as? ImageFullScreenViewController {
                imageFullScreenVC.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
