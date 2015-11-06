//
//  RegisterViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Zhe Cheng on 11/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set current view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SignUpBackground")!)
        self.automaticallyAdjustsScrollViewInsets = true
        
        // Set button layer
        self.processButton.layer.cornerRadius = 20; //half of the width
        
        // Hide Back button on navigation controller
        self.navigationItem.hidesBackButton = true

        // Setup scroll view
        self.signUpScrollView.scrollEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissInputView")
        self.signUpScrollView.addGestureRecognizer(tap)
    }
    
    // Frame will change after ViewWillAppear because of AutoLayout. 
    // All codes based on display frames should be called here after layouting subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set circular logo image view
        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2
        self.logoImageView.clipsToBounds = true
        self.logoImageView.layer.borderWidth = 1.0
        self.logoImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    // MARK: Actions
    // Cancel the registration process, back to the root of the view controller stack
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Action for the processButton
    @IBAction func nextProcess(sender: UIButton) {
        finishForm()
    }
    
    // Dismiss inputView when touching any other areas on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissInputView()
        super.touchesBegan(touches, withEvent: event)
    }

    //Calls this function when the tap is recognized to dismiss input view
    func dismissInputView() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        self.signUpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // MARK:TextField delegates and functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if nextResponder != nil {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
            finishForm()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var offsetY: CGFloat = 0.0
        let previousTag = textField.tag - 1;
        // Try to find next responder
        if let previousTextField = textField.superview?.viewWithTag(previousTag) as? UITextField {
            offsetY = previousTextField.frame.origin.y
        }
        
        self.signUpScrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        
    }
    
    // MARK: Abstract functions
    func finishForm() { }
}
