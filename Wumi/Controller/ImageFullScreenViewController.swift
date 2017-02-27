//
//  ImageFullScreenViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImageFullScreenViewController: UIViewController {
    /// Index of current displaying image.
    var currentIndex = 0 {
        didSet {
            self.updateIndexLabel()
        }
    }
    /// Flag indicating whether enable to save image or not.
    var enableSaveImage = false {
        didSet {
            guard let fullscreenView = self.view as? ImageFullScreenView else { return }
            
            fullscreenView.actionButton.hidden = !self.enableSaveImage
        }
    }
    /// Array of images to be displayed in this controller.
    lazy var images = [UIImage]()
    /// Array of image page view controllers to display each image.
    private lazy var imagePageItemVCs = [ImagePageItemViewController]()
    
    // MARK: Lifecycle methods
    
    override func loadView() {
        super.loadView()
        
        if let view = UINib(nibName: "ImageFullScreenView", bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            view.frame = self.view.frame
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fullscreenView = self.view as? ImageFullScreenView else { return }
        
        self.addChildViewController(fullscreenView.imagePageVC)
        fullscreenView.imagePageVC.didMoveToParentViewController(self)
        fullscreenView.dataSource = self
        fullscreenView.delegate = self
        fullscreenView.actionButton.hidden = !enableSaveImage
            
        self.loadPages()
    }
    
    // MARK: UI functions
    
    /**
     Update index label.
     */
    private func updateIndexLabel() {
        guard let fullscreenView = self.view as? ImageFullScreenView else { return }
        
        fullscreenView.indexLabel.text = "\(self.currentIndex + 1)/\(self.images.count)"
    }
    
    // MARK: Helper functions
    
    /**
     Load all image pages.
     */
    private func loadPages() {
        self.imagePageItemVCs.removeAll()
        
        for index in 0..<self.images.count {
            guard let image = self.images[safe: index] else { continue }
            
            let imagePageItemVC = ImagePageItemViewController()
            imagePageItemVC.image = image
            self.imagePageItemVCs.append(imagePageItemVC)
        }
        
        // Set first page
        if let startVC = imagePageItemVCs[safe: currentIndex],
            fullscreenView = self.view as? ImageFullScreenView {
                fullscreenView.imagePageVC.setViewControllers([startVC],
                                                              direction: .Forward,
                                                              animated: true,
                                                              completion: nil)
                self.updateIndexLabel()
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension ImageFullScreenViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        self.currentIndex = index
        
        return self.imagePageItemVCs[safe: self.currentIndex - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        self.currentIndex = index
        
        return self.imagePageItemVCs[safe: self.currentIndex + 1]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.imagePageItemVCs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let fullscreenView = self.view as? ImageFullScreenView,
            orderedVCs = fullscreenView.imagePageVC.viewControllers as? [ImagePageItemViewController],
            firstVC = orderedVCs.first,
            index = self.imagePageItemVCs.indexOf(firstVC) else { return 0 }
        
        return index
    }
}

// MARK: MoreButton delegate

extension ImageFullScreenViewController: MoreButtonDelegate {
    func showMoreActions(moreButton: MoreButton) {
        let imageActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Add save action to save image into album
        if enableSaveImage {
            imageActionSheet.addAction(UIAlertAction(title: "Save to Cameral Roll", style: .Default) { (action) in
                guard let image = self.images[safe: self.currentIndex] else { return }
                
                image.saveToLibrary(album: nil, completionHanlder: nil)
            })
        }
        
        // Present action sheet if we have any action
        if imageActionSheet.actions.count > 0 {
            // Add cancel action
            imageActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                imageActionSheet.dismissViewControllerAnimated(true, completion: nil)
            })
            self.presentViewController(imageActionSheet, animated: true, completion: nil)
        }
    }
}
