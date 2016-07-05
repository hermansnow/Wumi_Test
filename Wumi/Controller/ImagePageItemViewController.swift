//
//  ImagePageItemViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImagePageItemViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            if let imageView = self.imageView {
                imageView.image = self.image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = self.image
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapImage(_:)))
        
        // Add gestures
        self.view.addGestureRecognizer(tap)
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
