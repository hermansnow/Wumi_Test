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
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInputView))
        self.formScrollView.addGestureRecognizer(tap)
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
                                               selector: #selector(keyboardWillShown(_:)),
                                                   name: UIKeyboardWillShowNotification,
                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                               selector: #selector(keyboardWillHiden(_:)),
                                                   name: UIKeyboardWillHideNotification,
                                                 object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Actions
    
    // Scroll view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey],
            textField = UIResponder.currentFirstResponder() as? UITextField else { return }
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        if let textFieldOrigin = textField.superview?.convertPoint(textField.frame.origin, toView: self.view) {
            let overlapHeight = textFieldOrigin.y + keyboardRect.size.height - self.view.frame.size.height + textField.frame.size.height
            guard overlapHeight > 0 else { return }
            
            // Get keyboard animation duration
            var keyboardDuration: NSTimeInterval = 0.0
            keyboardDurVal.getValue(&keyboardDuration)
            // Scroll view
            UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
                self.formScrollView.setContentOffset(CGPointMake(0.0, overlapHeight), animated: false)
            })
        }
    }
    
    // Reset view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        // Scroll view
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.formScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        })
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
