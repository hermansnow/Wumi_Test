//
//  CacheSettingViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 8/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CacheSettingViewController: UIViewController {

    @IBOutlet weak var cacheSizeLabel: UILabel!
    
    // MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.   
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCurrentCacheSize()
    }

    // MARK: actions
    @IBAction func clearCache(sender: AnyObject) {
        DataManager.sharedDataManager.cleanMemoryCache()
        let fm = NSFileManager.defaultManager()
        do {
            let cachePaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            let cacheDirectory = cachePaths[0]
            let paths = try fm.contentsOfDirectoryAtPath(cacheDirectory)
            for path in paths
            {
                try fm.removeItemAtPath("\(cacheDirectory)/\(path)")
                print("delete file: \(cacheDirectory)/\(path)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        updateCurrentCacheSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: helper functions
    private func updateCurrentCacheSize() {
        let cacheSize = getCacheFolderSize()
        let mbSize = Double(cacheSize) / (1024 * 1024)
        cacheSizeLabel.text = String.init(format: "%4.2f MB", mbSize)

    }
    
    func getCacheFolderSize() -> UInt64 {
        let cachePaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cacheDirectory = NSURL.init(string: cachePaths[0])
        do {
            let FolderSize = try NSFileManager.defaultManager().allocatedSizeOfDirectoryAtURL(cacheDirectory!)
            return FolderSize
        } catch {
            print("error in allocatedSizeOfDirectoryAtURL")
            return 0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NSFileManager {
    
    /// This method calculates the accumulated size of a directory on the volume in bytes.
    ///
    /// As there's no simple way to get this information from the file system it has to crawl the entire hierarchy,
    /// accumulating the overall sum on the way. The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    
    func allocatedSizeOfDirectoryAtURL(directoryURL : NSURL) throws -> UInt64 {
        
        // We'll sum up content size here:
        var accumulatedSize = UInt64(0)
        
        // prefetching some properties during traversal will speed up things a bit.
        let prefetchedProperties = [
            NSURLIsRegularFileKey,
            NSURLFileAllocatedSizeKey,
            NSURLTotalFileAllocatedSizeKey,
            ]
        
        // The error handler simply signals errors to outside code.
        var errorDidOccur: NSError?
        let errorHandler: (NSURL, NSError) -> Bool = { _, error in
            errorDidOccur = error
            return false
        }
        
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumeratorAtURL(directoryURL,
                                              includingPropertiesForKeys: prefetchedProperties,
                                              options: NSDirectoryEnumerationOptions(),
                                              errorHandler: errorHandler)
        precondition(enumerator != nil)
        
        // Start the traversal:
        for item in enumerator! {
            let contentItemURL = item as! NSURL
            
            // Bail out on errors from the errorHandler.
            if let error = errorDidOccur { throw error }
            
            let resourceValueForKey: (String) throws -> NSNumber? = { key in
                var value: AnyObject?
                try contentItemURL.getResourceValue(&value, forKey: key)
                return value as? NSNumber
            }
            
            // Get the type of this item, making sure we only sum up sizes of regular files.
            guard let isRegularFile = try resourceValueForKey(NSURLIsRegularFileKey) else {
                preconditionFailure()
            }
            
            guard isRegularFile.boolValue else {
                continue
            }
            
            // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
            // This includes metadata, compression (on file system level) and block size.
            var fileSize = try resourceValueForKey(NSURLTotalFileAllocatedSizeKey)
            
            // In case the value is unavailable we use the fallback value (excluding meta data and compression)
            // This value should always be available.
            fileSize = try fileSize ?? resourceValueForKey(NSURLFileAllocatedSizeKey)
            
            guard let size = fileSize else {
                preconditionFailure("huh? NSURLFileAllocatedSizeKey should always return a value")
            }
            
            // We're good, add up the value.
            accumulatedSize += size.unsignedLongLongValue
        }
        
        // Bail out on errors from the errorHandler.
        if let error = errorDidOccur { throw error }
        
        // We finally got it.
        return accumulatedSize
    }
}
