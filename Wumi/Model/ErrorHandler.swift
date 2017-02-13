//
//  ErrorHandler.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct ErrorHandler {
    /**
     Log error message
     
    - Parameters:
        - errorMessage: error message string.
     */
    static func log(errorMessage: String?) {
        print(errorMessage)
    }
    
    /**
     Log a wumi error
     
     - Parameters:
        - error: Wumi error instance.
     */
    static func log(error: WumiError?) {
        if let wumiError = error {
            print("\(wumiError.error)")
        }
        else {
            print("Unknow error.")
        }
    }
    
    /**
     Pop up an UIAlertController for displaying error message
     
     - Parameters:
        - controller: Parent UIViewController to show this alert controller on.
        - errorMessage: Error message string.
        - dismissButtonTitle: Title of dismiss button. Default to be "Cancel".
        - handler: A block to execute when the user selects the dismiss button. This block has no return value and takes the button as its only parameter.
     */
    static func popupErrorAlert(controller: UIViewController, errorMessage: String?, dismissButtonTitle: String = "Cancel", handler: ((UIAlertAction) -> Void)? = nil) {
        guard let errorMessage = errorMessage else { return }
        
        let alert = UIAlertController(title: "Failed",
                                      message: errorMessage,
                                      preferredStyle: .Alert)
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: dismissButtonTitle,
                                      style: .Cancel,
                                      handler: handler))
        
        // Present alert controller
        controller.presentViewController(alert,
                                         animated: true,
                                         completion: nil)
    }
    
    /**
     Parse error.
     
     - Parameters:
        - error: NSError object includes error data.
     
     - Returns:
        An wumi error if error message found, otherwise nil.
     */
    static func parseError(error: NSError?) -> WumiError? {
        guard let error = error else {
            return nil
        }
        
        switch error.domain {
        case "AVOS Cloud Error Domain":
            return ErrorHandler.leanCloudError(error)
        case "Wumi":
            guard let wumiError = error as? WumiError else { return nil }
            return wumiError
        default:
            return nil
        }
    }
    
    /**
     Parse Error from LeanCloud server.
     
     - seealso:
        [LeanClound Error Code.](https://leancloud.cn/docs/error_code.html)
     
     - Parameters:
        - error: NSError object includes LeanCloud error data.
     
     - Returns:
        An wumi error object if error message found, otherwise nil.
     */
    static func leanCloudError(error: NSError) -> WumiError? {
        guard error.domain == "AVOS Cloud Error Domain" else { return nil } // Check error domain
        
        // Map error key: https://leancloud.cn/docs/error_code.html
        var type: WumiError.WumiErrorType = .Unknown
        switch error.code {
        case 125, 203:
            type = .Email
        case 200, 202, 217:
            type = .Name
        case 210:
            type = .Password
        case 122, 430:
            type = .Image
        default:
            break
        }
        if let errorMessage = error.userInfo["error"] as? String {
            return WumiError(type: type, error: errorMessage)
        }
        return nil
    }
}
