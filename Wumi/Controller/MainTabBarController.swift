//
//  MainTabBarController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    var lastItem: UITabBarItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MainTabBarController.refreshUponReceivingAPNS(_:)),
                                                         name:APNSReceivedNotificationIdentifier, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Save selected item as last item
        self.lastItem = self.tabBar.selectedItem
        
        let currentInstallation = AVInstallation.currentInstallation();
        currentInstallation["owner"] = User.currentUser()
        currentInstallation.saveInBackground()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Refresh controller view after receiving remote notification.
     
     - Parameter:
        - notification: Notification broadcasted for APN received event.
     */
    func refreshUponReceivingAPNS(notification: NSNotification) {
        guard let viewControllers = self.viewControllers,
            notificationNavigationController = viewControllers[safe: 3] as? UINavigationController,
            notificationController = notificationNavigationController.topViewController as? NotificationTableViewController else { return }
        
        if self.selectedViewController == notificationNavigationController {
            notificationController.loadPushNotifications() // Load push notification if we are showing the notification tab
        }
        else {
            notificationController.updatePushNotificationBadge() // Just update notification tab's badge if we are not showing it
        }
    }
    
    // MARK: UITabBar delegate
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        // Post notification for clicking current selected tab bar item
        if self.lastItem == item {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.General.TabBarItemDidClickSelf, object: nil)
        }
        
        self.lastItem = item
    }
}
