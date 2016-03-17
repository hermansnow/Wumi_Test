//
//  ScrollTextFieldViewController.swift
//  Wumi
//
//  Created by Herman on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class ScrollTextFieldViewController: UIViewController {
    
    @IBOutlet weak var formScrollView: UIScrollView!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Setup scroll view
        self.formScrollView.scrollEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "dismissInputView")
        self.formScrollView.addGestureRecognizer(tap)
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
                                               selector: "keyboardWasShown:",
                                                   name: UIKeyboardWillShowNotification,
                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                               selector: "keyboardWillHiden:",
                                                   name: UIKeyboardWillHideNotification,
                                                 object: nil)
    }
    
    // MARK: Actions
    
    // Scroll view when showing the keyboard
    func keyboardWasShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
               keyboardRect = keyboardInfo["UIKeyboardFrameEndUserInfoKey"]?.CGRectValue(),
               textField = UIResponder.currentFirstResponder() as? UITextField else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.size.height, right: 0)
        self.formScrollView.contentInset = contentInsets
        self.formScrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        var visibleRect = self.view.frame
        visibleRect.size.height -= keyboardRect.size.height
        if !CGRectContainsPoint(visibleRect, textField.frame.origin) {
            self.formScrollView.setContentOffset(CGPointMake(0.0, textField.frame.origin.y - keyboardRect.size.height),
                                       animated: true)
        }
    }
    
    // Reset view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        formScrollView.contentInset = UIEdgeInsetsZero
        formScrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        self.formScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // Dismiss inputView when touching any other areas on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func dismissInputView() {
        self.view.endEditing(true)
    }
}
