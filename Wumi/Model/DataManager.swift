//
//  DataManager.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import CoreData
import SDWebImage

class DataManager {
    
    static let sharedDataManager = DataManager() // Singleton instance
    
    init() {
        self.cache.countLimit = 1000
    }
    
    // MARK: In-memory cache
    
    /// NSCache object for in-memory cache.
    lazy var cache = NSCache()
    /// SDImageCache object for local image cache.
    lazy var imageCache = SDImageCache()
    
    // MARK: Disk File Manager
    
    func createDataDirectory(fileName: String) -> Bool {
        guard let path = self.pathForDataFile(fileName) else { return false }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("failed to create file directory")
            return false
        }
        
        return true
    }
    
    // Get path of data store on disk
    func pathForDataFile(fileName: String) -> String? {
        let documentDirArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        guard let path = documentDirArray.first else { return nil }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("failed to create file directory")
        }
        
        print("\(path)/\(fileName).bin")
        return "\(path)/\(fileName).bin"
    }
    
    // Load and save disk directory files
    func loadDataFromDisk(fileName: String, cacheKey: String) -> AnyObject? {
        guard let path = self.pathForDataFile(fileName), rootObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path) else { return nil }
        
        print(rootObject)
        self.cache.setObject(rootObject, forKey: cacheKey)
        return rootObject
    }
    
    func saveDataToDisk(fileName: String, cacheKey: String) {
        // User cache
        if let path = self.pathForDataFile(fileName), rootObject = self.cache.objectForKey(cacheKey) {
            NSKeyedArchiver.archiveRootObject(rootObject, toFile: path)
        }
    }
    
    /**
     Clean memory cache.
     */
    func cleanMemoryCache() {
        self.cache.removeAllObjects()
        self.imageCache.clearMemory()
    }
    
    // MARK: Core Data
    
    func getManagerObjectContext() -> NSManagedObjectContext? {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            return appDelegate.managedObjectContext
        }
        else {
            return nil
        }
    }
    
    // MARK: Help Functions
    
    /**
     Log message.
     
     - Parameters:
        - message: Data management information message string.
     */
    class func log(message: String?) {
        print(message)
    }
}

// Extension for NSCache to support expiration

protocol TimeBaseCacheable: AnyObject {
    var expireAt: NSDate? { get set }
    var maxCacheAge: NSTimeInterval? { get set }
}

extension NSCache {
    subscript(key: AnyObject) -> TimeBaseCacheable? {
        get {
            if let obj = objectForKey(key) as? TimeBaseCacheable, expireDate = obj.expireAt {
                if  NSDate().compare(expireDate) == .OrderedDescending {
                    removeObjectForKey(key)
                }
            }
            
            return objectForKey(key) as? TimeBaseCacheable
        }
        set {
            if let value = newValue {
                setObject(value, forKey: key)
                if let age = value.maxCacheAge {
                    value.expireAt = NSDate(timeIntervalSinceNow: age)
                }
            }
            else {
                removeObjectForKey(key)
            }
        }
    }
}
