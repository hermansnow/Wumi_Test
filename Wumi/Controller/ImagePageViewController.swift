//
//  ImagePageViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImagePageViewController: UIPageViewController {
    
    var startIndex = 0
    lazy var images = [UIImage]()
    private var imagePageItemVCs = [ImagePageItemViewController]()
    private var indexLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.view.addSubview(self.indexLabel)
        self.view.bringSubviewToFront(self.indexLabel)
        
        //self.addConstraints()
        
        self.loadPages()
    }
    
    // MARK: Helper functions
    /*private func addConstraints() {
        //self.view.translatesAutoresizingMaskIntoConstraints = false
        
        //self.pageVC.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.pageVC.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        self.pageVC.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.pageVC.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        
        NSLayoutConstraint(item: self.indexLabel,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .CenterX,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: self.indexLabel,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Top,
                           multiplier: 1,
                           constant: 0).active = true
    }*/
    
    private func loadPages() {
        for index in 0..<self.images.count {
            guard let image = self.images[safe: index],
                imagePageItemVC = storyboard!.instantiateViewControllerWithIdentifier("ImagePageItemViewController") as? ImagePageItemViewController else { continue }
            imagePageItemVC.image = image
            imagePageItemVC.itemIndex = index
            imagePageItemVC.itemCount = self.images.count
            self.imagePageItemVCs.append(imagePageItemVC)
        }
        
        // Set first page
        if let startVC = imagePageItemVCs[safe: startIndex] {
            self.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
            self.indexLabel.textColor = UIColor.whiteColor()
            self.indexLabel.text = "\(self.startIndex + 1)/\(self.images.count)"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIPageViewControllerDataSource
extension ImagePageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
        index = self.imagePageItemVCs.indexOf(imagePageItemVC) where index >= 1 && index < self.imagePageItemVCs.count else { return nil }
        
        return self.imagePageItemVCs[safe: index - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) where index >= 0 && index < self.imagePageItemVCs.count - 1 else { return nil }
        
        return self.imagePageItemVCs[safe: index + 1]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.imagePageItemVCs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let orderedVCs = self.viewControllers as? [ImagePageItemViewController],
            firstVC = orderedVCs.first,
            index = self.imagePageItemVCs.indexOf(firstVC) else { return 0 }
        
        return index
    }
}
