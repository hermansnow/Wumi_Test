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
        self.registerClass()
        
        // Set up appearance
        self.setupAppearance()
        
        // Set up AVOSCloud
        self.setupAVOSCloudSetting()
        
        // Set initial view controller
        self.setupLaunchViewController()
        
        // Load cached data from disk into memory
        self.loadDataFromDisk()
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        self.saveDataToDisk()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.saveDataToDisk()
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        self.clearMemoryCache()
    }
    
    // Register classes
    private func registerClass() {
        Profession.registerSubclass()
        Post.registerSubclass()
        PostCategory.registerSubclass()
        Comment.registerSubclass()
    }
    
    // Set up application level appearance
    private func setupAppearance() {
        // Set Navigation bar color
        UINavigationBar.appearance().barTintColor = Constants.General.Color.ThemeColor
        UINavigationBar.appearance().tintColor = Constants.General.Color.TintColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Constants.General.Color.TitleColor]
        UINavigationBar.appearance().translucent = false
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self]).tintColor = Constants.General.Color.TintColor
        
        // Set Tab bar color
        UITabBar.appearance().barTintColor = Constants.General.Color.ThemeColor
        UITabBar.appearance().tintColor = Constants.General.Color.TintColor
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Constants.General.Color.TitleColor], forState: .Normal)
        UITabBar.appearance().translucent = false
        
        // Set status bar
        setStatusBarBackgroundColor(Constants.General.Color.ThemeColor)
    }
    
    // Customize the status bar
    private func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    // Set up the initial launch view controller
    private func setupLaunchViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let user = User.currentUser() {
            user.fetchInBackgroundWithBlock(nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        else {
            let loginNavigation = storyboard.instantiateViewControllerWithIdentifier("Sign In Navigation Controller")
            window?.rootViewController = loginNavigation
        }
    }
    
    // Set up AVOSCloud
    private func setupAVOSCloudSetting() {
        //AVOSCloud.setAllLogsEnabled(true)
        AVOSCloud.setServiceRegion(.US)
        AVOSCloud.setApplicationId("WtWKobgICmjMgPlmNBiVaeme-MdYXbMMI", clientKey: "OEKOIcQ7Wjnk4wuurFNlvmO1")
        // China Setting
        //AVOSCloud.setServiceRegion(.CN)
        //AVOSCloud.setApplicationId("ts61qva17BjxVjuLvLk3Vh5o-gzGzoHsz", clientKey: "46fHDW8yFvxaVo5DoTjT0yPE")
    }
    
    // Local cached data from disk
    private func loadDataFromDisk() {
        DataManager.loadAllDataFromDisk()
    }
    
    private func saveDataToDisk() {
        DataManager.SaveAllDataToDisk()
    }
    
    private func clearMemoryCache() {
        AVFile.clearAllCachedFiles()
        AVQuery.clearAllCachedResults()
    }
}
