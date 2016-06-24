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
    var image: UIImage? {
        didSet {
            if let imageView = self.imageView {
                imageView.image = self.image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.General.Color.BackgroundColor
        
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = self.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
