//
//  DataManager.swift
//  Wumi
//
//  Created by Zhe Cheng on 4/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct DataManager {
    static var cache = NSCache()
    
    static func createDataDirectory(fileName: String) -> Bool {
        guard let path = DataManager.pathForDataFile(fileName) else { return false }
        
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
    static func pathForDataFile(fileName: String) -> String? {
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
    
    static func loadAllDataFromDisk() {
        DataManager.loadDataFromDisk(User.diskFileName, cacheKey: "users")
    }
    
    static func loadDataFromDisk(fileName: String, cacheKey: String) -> AnyObject? {
        guard let path = DataManager.pathForDataFile(fileName), rootObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path) else { return nil }
        
        print(rootObject)
        DataManager.cache.setObject(rootObject, forKey: cacheKey)
        return rootObject
    }
    
    static func SaveAllDataToDisk() {
        DataManager.saveDataToDisk(User.diskFileName, cacheKey: "users")
    }
    
    static func saveDataToDisk(fileName: String, cacheKey: String) {
        // User cache
        if let path = DataManager.pathForDataFile(fileName), rootObject = self.cache.objectForKey(cacheKey) {
            NSKeyedArchiver.archiveRootObject(rootObject, toFile: path)
        }
    }
}