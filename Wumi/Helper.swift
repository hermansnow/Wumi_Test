//
//  Helper.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class Helper {
    
    // Redirect to Sign in UIViewController
    static func RedirectToSignIn (controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("Log In View Controller")
        controller.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    // Popup an UIAlertController for error message
    static func PopupErrorAlert (controller: UIViewController, errorMessage: String, dismissButtonTitle: String = "Cancel") {
        let alert = UIAlertController(title: "Failed", message: errorMessage, preferredStyle: .Alert)
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .Cancel, handler: nil))
        
        // Present alert controller
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Popup an UIAlertController for showing information
    static func PopupInformationBox (controller: UIViewController, boxTitle: String, message: String) {
        let alert = UIAlertController(title: boxTitle, message: message, preferredStyle: .Alert)
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        // Present alert controller
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func PopupInputBox (controller: UIViewController, boxTitle: String, message: String, numberOfFileds: Int, textValues: [[String: String]], WithBlock block: (inputValues: [String?]) -> Void) {
        let alert = UIAlertController(title: boxTitle, message: message, preferredStyle: .Alert)
        
        // Add an input text field
        
        for index in 0..<numberOfFileds {
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Set initial
                textField.text = textValues[index]["originalValue"]
                textField.placeholder = textValues[index]["placeHolder"]
                textField.clearButtonMode = .WhileEditing
            }
        }
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action) -> Void in
            if let textFields = alert.textFields {
                var inputValues = [String?]()
                for index in 0..<numberOfFileds {
                    inputValues.append(textFields[index].text)
                }
                block(inputValues: inputValues)
            }
        }))
        
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}