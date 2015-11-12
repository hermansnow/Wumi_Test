//
//  WMRegisterViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class WMRegisterViewController: WMTextFieldViewController {
    
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set current view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SignUpBackground")!)
        self.automaticallyAdjustsScrollViewInsets = true
        
        // Show navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Set Logo view
        self.logoImageView.image = UIImage(named: "Profile")
        self.logoImageView.sizeToFit()
        
        // Set button layer
        self.processButton.layer.cornerRadius = 20; //half of the width
        
        // Hide Back button on navigation controller
        self.navigationItem.hidesBackButton = true
    }
    
    // Frame will change after ViewWillAppear because of AutoLayout. 
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set circular logo image view
        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2
        self.logoImageView.clipsToBounds = true
    }
    
    // MARK: Actions
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Dismiss inputView when touching any other areas on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.dismissInputView()
        super.touchesBegan(touches, withEvent: event)
    }
}
