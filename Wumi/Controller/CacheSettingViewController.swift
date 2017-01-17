//
//  CacheSettingTableViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 8/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class CacheSettingTableViewController: UITableViewController {

    @IBOutlet weak var cacheSizeLabel: UILabel!
    @IBOutlet weak var largeCacheSizeLabel: UILabel!
    
    /// Minimum size of large file.
    private let largeFileSize = 50
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Calculate cache usage
        self.calculateCacheSize()
        self.calculateLargeFileSize()
    }
    
    // MARK: UITableViewController delegates
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard self.cacheSizeLabel.text != "Calculating..." else { break }
                
                self.clearAllCache()
            case 1:
                guard self.largeCacheSizeLabel.text != "Calculating..." else { break }
                
                self.clearLargeFiles()
            default:
                break
            }
        default:
            break
        }
        
        // Deselect cell
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    // MARK: Actions
    
    /**
     Calculate usage of all cache asynchronously.
     */
    private func calculateCacheSize() {
        // Calculating
        self.cacheSizeLabel.text = "Calculating..."
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let list = self.getCacheFilesLargerThan(0)
            let fm = NSFileManager.defaultManager()
            var totalSize = 0
            do {
                for filePath in list {
                    let attr = try fm.attributesOfItemAtPath(filePath)
                    let fileSize = attr[NSFileSize] as! NSNumber
                    totalSize += Int(fileSize)
                }
            }
            catch let error as NSError {
                ErrorHandler.log(error.localizedDescription)
            }
            
            let mbSize = Double(totalSize) / (1024 * 1024)
            
            // Back to main process
            dispatch_async(dispatch_get_main_queue()) {
                self.cacheSizeLabel.text = String.init(format: "%4.2f MB", mbSize)
            }
        }
        
    }
    
    /**
     Calculate size of all cached files asynchronously.
     */
    private func calculateLargeFileSize() {
        // Calculating
        self.largeCacheSizeLabel.text = "Calculating..."
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let list = self.getCacheFilesLargerThan(self.largeFileSize)
            let fm = NSFileManager.defaultManager()
            var totalSize = 0
            do {
                for filePath in list {
                    let attr = try fm.attributesOfItemAtPath(filePath)
                    let fileSize = attr[NSFileSize] as! NSNumber
                    totalSize += Int(fileSize)
                }
            }
            catch let error as NSError {
                ErrorHandler.log(error.localizedDescription)
            }
            let mbSize = Double(totalSize) / (1024 * 1024)
            
            // Back to main process
            dispatch_async(dispatch_get_main_queue()) {
                self.largeCacheSizeLabel.text = String.init(format: "%4.2f MB", mbSize)
            }
        }
    }
    
    /**
     Clean all cached data.
     */
    private func clearAllCache() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Clear", style: .Default) { (UIAlertAction) in
            // Clean disk memory cache
            DataManager.sharedDataManager.cleanMemoryCache()
            
            // Clean user defaults
            if let bundle = NSBundle.mainBundle().bundleIdentifier {
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(bundle)
            }
            
            // Clean cached files
            self.clearCacheLargerThan(0)
            
            // Re-calculate usage of cache
            self.calculateCacheSize()
            self.calculateLargeFileSize()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Clean all large cached files.
     */
    private func clearLargeFiles() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Clear", style: .Default) { (UIAlertAction) in
                // Clean cached files
                self.clearCacheLargerThan(self.largeFileSize)
            
                // Re-calculate size of cached files
                self.calculateLargeFileSize()
                self.calculateCacheSize()
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper functions
    
    /**
     Clear cached files larger than a specific size.
     
     - Parameters:
        - minSize: minimum file size.
     */
    private func clearCacheLargerThan(fileSize: Int) {
        let list = self.getCacheFilesLargerThan(fileSize)
        let fm = NSFileManager.defaultManager()
        for path in list {
            do {
                try fm.removeItemAtPath(path)
                DataManager.log("delete file: \(path)")
            }
            catch let error as NSError {
                ErrorHandler.log(error.localizedDescription)
            }
        }
    }
    
    /**
     Get cached files larger than a specific size.
     
     - Parameters:
        - minSize: minimum file size.
     
     - Returns:
        Array of file paths.
     */
    private func getCacheFilesLargerThan(minSize: Int) -> [String] {
        var fileList = [String]()
        let cachePaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        for cacheDirectory in cachePaths {
            fileList.appendContentsOf(NSFileManager.defaultManager().listFileAtPath(cacheDirectory, largerThan: minSize))
        }
        return fileList
    }

}
