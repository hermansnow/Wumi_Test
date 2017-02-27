//
//  ImageFullScreenView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/7/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImageFullScreenView: UIView {
    @IBOutlet weak var actionButton: MoreButton!
    @IBOutlet weak var indexLabel: UILabel!
    
    /// Page view controller to show a list of images.
    var imagePageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    /// Data source of UIPageViewController
    var dataSource: UIPageViewControllerDataSource? {
        didSet {
            self.imagePageVC.dataSource = self.dataSource
        }
    }
    /// More button delegate.
    var delegate: protocol<MoreButtonDelegate>? {
        didSet {
            self.actionButton.delegate = self.delegate
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add contain VC
        self.addSubview(self.imagePageVC.view)
        self.imagePageVC.view.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        self.imagePageVC.view.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        self.imagePageVC.view.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        self.imagePageVC.view.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        self.imagePageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set property for page VC
        self.imagePageVC.view.backgroundColor = UIColor.blackColor()
        
        // Set property for index label
        self.indexLabel.textColor = UIColor.whiteColor()
        self.indexLabel.backgroundColor = UIColor.clearColor()
        self.indexLabel.textAlignment = .Center
        
        // Show components
        self.bringSubviewToFront(self.indexLabel)
        self.bringSubviewToFront(self.actionButton)
    }
}
