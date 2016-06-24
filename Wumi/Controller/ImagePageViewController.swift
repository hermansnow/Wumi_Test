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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.loadPages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helper functions
    private func loadPages() {
        for image in images {
            guard let imagePageItemVC = storyboard!.instantiateViewControllerWithIdentifier("ImagePageItemViewController") as? ImagePageItemViewController else { continue }
            imagePageItemVC.image = image
            self.imagePageItemVCs.append(imagePageItemVC)
        }
        
        // Set first page
        if let startVC = imagePageItemVCs[safe: startIndex] {
            self.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
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
}
