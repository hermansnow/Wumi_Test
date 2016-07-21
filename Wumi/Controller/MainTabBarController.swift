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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Save selected item as last item
        self.lastItem = self.tabBar.selectedItem
        
        let currentInstallation = AVInstallation.currentInstallation();
        currentInstallation["owner"] = User.currentUser()
        currentInstallation.saveInBackground()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.refreshUponReceivingAPNS(_:)), name:APNSReceivedNotificationIdentifier, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refreshUponReceivingAPNS (notification: NSNotification) {
        let notificationNavigationController = self.viewControllers![3] as? UINavigationController
        let notificationController = notificationNavigationController?.topViewController as? NotificationTableViewController
        notificationController?.tableView.reloadData()
        self.selectedIndex = 3
        notificationNavigationController?.tabBarItem.badgeValue = String(notificationController!.currentUser.pushNotificationsArray.count)
    }
    
    // MARK: UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        // Post notification for clicking current selected tab bar item
        if self.lastItem == item {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.General.TabBarItemDidClickSelf, object: nil)
        }
        
        self.lastItem = item
    }
}
