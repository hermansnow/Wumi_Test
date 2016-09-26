//
//  Extension+UIViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import TSMessages
import ReachabilitySwift

extension UIViewController {
    // Dismiss inputView when touching any other areas on the screen
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func dismissInputView() {
        self.view.endEditing(true)
    }
    
    // MARK - Reachability
    
    func checkReachability() {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate, reachability = delegate.reachability {
            if !reachability.isReachable() {
                self.showReachabilityError()
            }
        }
    }
    
    func showReachabilityError() {
        print("Show Error")
        TSMessage.showNotificationInViewController(self.parentViewController,
                                                   title: "Network error",
                                                   subtitle: "Couldn't connect to the server. Check your network connection.",
                                                   image: nil,
                                                   type: .Error,
                                                   duration: NSTimeInterval(TSMessageNotificationDuration.Endless.rawValue),
                                                   callback: nil,
                                                   buttonTitle: nil,
                                                   buttonCallback: nil,
                                                   atPosition: TSMessageNotificationPosition.Top,
                                                   canBeDismissedByUser: true)
    }
    
    func dismissReachabilityError() {
        TSMessage.dismissActiveNotification()
    }
    
    func reachabilityChanged(notification: NSNotification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        if !reachability.isReachable() {
            self.showReachabilityError()
        }
        else {
            TSMessage.dismissActiveNotification()
        }
    }
}
