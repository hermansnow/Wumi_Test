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
    
    var itemIndex = 0
    var itemCount = 0
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapImage(gesture: UIGestureRecognizer) {
        if let pageVC = self.parentViewController as? ImagePageViewController {
            pageVC.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
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
