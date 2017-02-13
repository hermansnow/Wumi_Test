/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import AVOSCloud
import ReachabilitySwift
import CoreData
import FBSDKCoreKit

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

let APNSReceivedNotificationIdentifier = "APNSReceivedNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?
    var launchPostId: String?
    var backgroundedDate: NSDate?

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
        
        // Set up reachability
        self.setupReachability()
        
        // Social Network registration
        self.setupSocialNetworking(application, launchOptions: launchOptions)
        
        // Set up Chat manager
        CDChatManager.sharedManager().userDelegate = IMUserFactory()

        // Set up intial launch vc
        self.setupLaunchViewController(launchOptions)
        
        // Check launch URL
        if let options = launchOptions, url = options[UIApplicationLaunchOptionsURLKey] as? NSURL {
            WXApi.handleOpenURL(url, delegate: self)
            WeiboSDK.handleOpenURL(url, delegate: self)
            handleUrlQuery(url)
            
            FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                  openURL: url,
                                                                  sourceApplication: nil,
                                                                  annotation: nil)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        self.backgroundedDate = NSDate() // Log current time of entering background
        DataManager.sharedDataManager.cleanMemoryCache()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Force automatically log out if the application stayed on background for more than a day
        if let backgroundedDate = self.backgroundedDate where abs(backgroundedDate.timeIntervalSinceNow) > 60 * 60 * 24 {
            Helper.LogOut()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        DataManager.sharedDataManager.cleanMemoryCache()
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        DataManager.sharedDataManager.cleanMemoryCache()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // Broadcast APN received notification
        NSNotificationCenter.defaultCenter().postNotificationName(APNSReceivedNotificationIdentifier, object:nil)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        guard let currentInstallation = AVInstallation.currentInstallation() else {return}
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    // Handle custom scheme and URL
    func application(application: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        WXApi.handleOpenURL(url, delegate: self)
        WeiboSDK.handleOpenURL(url, delegate: self)
        handleUrlQuery(url)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        WXApi.handleOpenURL(url, delegate: self)
        WeiboSDK.handleOpenURL(url, delegate: self)
        handleUrlQuery(url)
        
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              openURL: url,
                                                              sourceApplication: sourceApplication,
                                                              annotation: annotation)
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        handleUrlQuery(url)
        
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return false }
        
        if handleUrlQuery(url) {
            return true
        }
        
        let webpageUrl = NSURL(string: "https://wumi.herokuapp.com/")!
        application.openURL(webpageUrl)
        
        return false
    }
    
    private func handleUrlQuery(url: NSURL) -> Bool {
        guard let query = url.query else { return false }
        
        let components = query.componentsSeparatedByString("&")
        
        for component in components {
            let pair = component.componentsSeparatedByString("=")
            guard let command = pair.first, value = pair[safe: 1] else { continue }
            
            if command.lowercaseString == "p" {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.General.CustomURLIdentifier, object:value)
                self.launchPostId = value
                return true
            }
        }
        
        return false
    }
    
    // Register classes
    private func registerClass() {
        Profession.registerSubclass()
        Post.registerSubclass()
        PostCategory.registerSubclass()
        Comment.registerSubclass()
        PushNotification.registerSubclass()
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
        
        // Set refresh controller
        UIRefreshControl.appearance().tintColor = Constants.General.Color.ThemeColor
    }
    
    // Customize the status bar
    private func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    // Set up the initial launch view controller
    private func setupLaunchViewController(launchOptions: [NSObject: AnyObject]?) {
        if let user = User.currentUser() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
            
            // Open chat manager
            CDChatManager.sharedManager().openWithClientId(user.objectId, callback: { (result: Bool, error: NSError!) -> Void in
                if (error == nil) {
                    user.fetchInBackgroundWithBlock(nil)
                }
            })
        }
        else {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
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
        
        // Use Dev mode notification now. TODO: Change to production when release
        AVPush.setProductionMode(false)
        AVOSCloud.registerForRemoteNotification()
    }
    
    // Set up social network accounts
    private func setupSocialNetworking(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        // Register weixin SDK
        WechatService.registerApp()
        
        // Register weibo SDK
        WeiboService.registerApp()
        
        // Register Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Set up reachability
    private func setupReachability() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
        }
        catch {
            print("Unable to create Reachability")
            return
        }
        do{
            if let reachability = self.reachability {
                try reachability.startNotifier()
            }
        }
        catch{
            print("could not start reachability notifier")
        }
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

// MARK: WeiboSDK delegate

extension AppDelegate: WeiboSDKDelegate {
    func didReceiveWeiboRequest(request: WBBaseRequest){
        print("request")
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse){
        print("response")
    }
}

// MARK: WeixinSDK delegate

extension AppDelegate: WXApiDelegate {
    func onReq(req: BaseReq!) {
        if let request = req as? ShowMessageFromWXReq {
            if let urlString = WechatService.getPostUrl(request.message), url = NSURL(string: urlString) {
                self.handleUrlQuery(url)
            }
            else {
                print("unknow message")
            }
        }
        else if let _ = req as? LaunchFromWXReq {
            print("launch")
        }
        else if let _ = req as? GetMessageFromWXReq {
            print("get messsage from wechat")
        }
        if let _ = req as? SendMessageToWXReq {
            print("send message to wechat")
        }
        else {
            print("unknown request")
        }
    }
    
    func onResp(resp: BaseResp!) {
        print("response")
    }
}
