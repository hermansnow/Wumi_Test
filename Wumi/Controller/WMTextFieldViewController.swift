//
//  WMTextFieldViewController.swift
//  Wumi
//
//  Created by Herman on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class WMTextFieldViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var formScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Setup scroll view
        self.formScrollView.scrollEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissInputView")
        self.formScrollView.addGestureRecognizer(tap)
    }
    
    // MARK: Actions
    // Dismiss inputView when touching any other areas on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissInputView()
        super.touchesBegan(touches, withEvent: event)
    }
    
    //Calls this function when the tap is recognized to dismiss input view
    func dismissInputView() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        self.formScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
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
        
        self.formScrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
}
