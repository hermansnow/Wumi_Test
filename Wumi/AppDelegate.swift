/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import AVOSCloud

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register classes
        Contact.registerSubclass()
        Profession.registerSubclass()
        
        // Set Navigation bar color
        UINavigationBar.appearance().barTintColor = Constants.General.Color.ThemeColor
        UINavigationBar.appearance().tintColor = Constants.General.Color.TintColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Constants.General.Color.TitleColor]
        UINavigationBar.appearance().translucent = false
        
        // Set up AVOSCloud
        setupAVOSCloudSetting()
        
        // Set initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let user = User.currentUser() {
            user.fetchInBackgroundWithBlock(nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        else {
            let loginNavigation = storyboard.instantiateViewControllerWithIdentifier("Sign In Navigation Controller")
            window?.rootViewController = loginNavigation
        }
        
        return true
    }
    
    // Set up AVOSCloud
    func setupAVOSCloudSetting() {
        AVOSCloud.setAllLogsEnabled(true)
        AVOSCloud.setServiceRegion(.US)
        AVOSCloud.setApplicationId("WtWKobgICmjMgPlmNBiVaeme-MdYXbMMI", clientKey: "OEKOIcQ7Wjnk4wuurFNlvmO1")
        // China Setting
        //AVOSCloud.setServiceRegion(.CN)
        //AVOSCloud.setApplicationId("ts61qva17BjxVjuLvLk3Vh5o-gzGzoHsz", clientKey: "46fHDW8yFvxaVo5DoTjT0yPE")
    }
}
