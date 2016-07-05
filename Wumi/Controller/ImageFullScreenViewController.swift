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
    
    var currentIndex = 0
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
        if let startVC = imagePageItemVCs[safe: currentIndex] {
            self.imagePageVC.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
            self.updateIndex()
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
    
    // MARK: Actions
    
    @IBAction func showImageActions(sender: AnyObject) {
        let imageActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Add save action to save image into album
        imageActionSheet.addAction(UIAlertAction(title: "Save to Cameral Roll", style: .Default) { (action) in
            guard let image = self.images[safe: self.currentIndex] else { return }
            
            image.saveToLibrary(album: nil, completionHanlder: nil)
        })
        
        // Add cancel action
        imageActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            imageActionSheet.dismissViewControllerAnimated(true, completion: nil)
        })
        
        self.presentViewController(imageActionSheet, animated: true, completion: nil)
    }
    
    // MARKL Helper functions
    private func updateIndex() {
        self.indexLabel.text = "\(self.currentIndex + 1)/\(self.images.count)"
    }
    
}

// MARK: UIPageViewControllerDataSource
extension ImageFullScreenViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        self.currentIndex = index
        self.updateIndex()
        
        return self.imagePageItemVCs[safe: self.currentIndex - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let imagePageItemVC = viewController as? ImagePageItemViewController,
            index = self.imagePageItemVCs.indexOf(imagePageItemVC) else { return nil }
        
        self.currentIndex = index
        self.updateIndex()
        
        return self.imagePageItemVCs[safe: self.currentIndex + 1]
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
