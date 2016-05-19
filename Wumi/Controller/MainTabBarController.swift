//
//  MainTabBarController.swift
//  Wumi
//
//  Created by Zhe Cheng on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
}
