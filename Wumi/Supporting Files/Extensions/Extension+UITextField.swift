//
//  Extension+UITextField.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension UITextField {
    // Return next responding textfield based on tag order
    func nextResponderTextField() -> UITextField? {
        let nextTag = self.tag + 1;
        
        // Try to find next responder
        guard let rootView = self.window, nextResponder = rootView.viewWithTag(nextTag) as? UITextField else { return nil }
        
        return nextResponder
    }
    
    // a computed property for setting left space of textfield
    var leftSpacing: CGFloat {
        get {
            if let leftView = self.leftView {
                return leftView.frame.size.width
            }
            else {
                return 0
            }
        }
        set {
            let leftSpacingFrame = CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height)
            if let leftView = self.leftView {
                leftView.frame = leftSpacingFrame
            }
            else {
                self.leftView = UIView(frame: leftSpacingFrame)
            }
            self.leftViewMode = .Always
        }
    }
}