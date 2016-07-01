//
//  ImageFullScreenViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 6/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ImageFullScreenViewController: UIViewController {
    
    @IBOutlet weak var indexLabel: UILabel!
    
    var startIndex = 0
    lazy var images = [UIImage]()
    private var imagePageVC = UIPageViewController()
    private var imagePageItemVCs = [ImagePageItemViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indexLabel.textColor = UIColor.whiteColor()
        self.indexLabel.backgroundColor = UIColor.blackColor()
        self.indexLabel.textAlignment = .Center
        
        self.imagePageVC.view.backgroundColor = UIColor.blackColor()
    }
    
    private func loadPages() {
        self.imagePageItemVCs.removeAll()
        
        for index in 0..<self.images.count {
            guard let image = self.images[safe: index],
                imagePageItemVC = storyboard!.instantiateViewControllerWithIdentifier("ImagePageItemViewController") as? ImagePageItemViewController else { continue }
            imagePageItemVC.image = image
            self.imagePageItemVCs.append(imagePageItemVC)
        }
        
        // Set first page
        if let startVC = imagePageItemVCs[safe: startIndex] {
            self.imagePageVC.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
            self.indexLabel.text = "\(self.startIndex + 1)/\(self.images.count)"
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let imagePageVC = segue.destinationViewController as? UIPageViewController where segue.identifier == "Show Image Pager" {
            self.imagePageVC = imagePageVC
            self.imagePageVC.hidesBottomBarWhenPushed = true
            self.imagePageVC.dataSource = self
            
            self.loadPages()
        }
    }
}

// MARK: UIPageViewControllerDataSource
extension ImageFullScreenViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        print("befero \(index)")
        self.indexLabel.text = "\(index + 1)/\(self.images.count)"
        
        return self.imagePageItemVCs[safe: index - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        print("after \(index)")
        self.indexLabel.text = "\(index + 1)/\(self.images.count)"
        
        return self.imagePageItemVCs[safe: index + 1]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.imagePageItemVCs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let orderedVCs = self.imagePageVC.viewControllers as? [ImagePageItemViewController],
            firstVC = orderedVCs.first,
            index = self.imagePageItemVCs.indexOf(firstVC) else { return 0 }
        return index
    }
}
