/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import AVOSCloud
import CoreData

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
        
        CDChatManager.sharedManager().userDelegate = IMUserFactory()
        if let user = User.currentUser() {
            CDChatManager.sharedManager().openWithClientId(user.email, callback: { (result: Bool, error: NSError!) -> Void in
                if (error == nil) {
                    // Set initial view controller
                    self.setupLaunchViewController()
                }
            })
        } else {
            self.setupLaunchViewController()
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        DataManager.sharedDataManager.cleanMemoryCache()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        DataManager.sharedDataManager.cleanMemoryCache()
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        DataManager.sharedDataManager.cleanMemoryCache()
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
        // Set general tint color
        self.window?.tintColor = Constants.General.Color.ThemeColor
        
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
            CDChatManager.sharedManager().openWithClientId(user.email, callback: { (result: Bool, error: NSError!) -> Void in
                if (error == nil) {
                    user.fetchInBackgroundWithBlock(nil)
                    self.window?.rootViewController = storyboard.instantiateInitialViewController()
                }
            })
//            user.fetchInBackgroundWithBlock(nil)
//            window?.rootViewController = storyboard.instantiateInitialViewController()
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
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Wumi" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Wumi", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
