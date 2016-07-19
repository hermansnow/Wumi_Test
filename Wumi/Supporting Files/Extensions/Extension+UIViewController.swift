//
//  Extension+UIViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension UIViewController {
    // Dismiss inputView when touching any other areas on the screen
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func dismissInputView() {
        self.view.endEditing(true)
    }
}