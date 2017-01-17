//
//  Helper.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class Helper {
    
    /**
     Redirect to sign-in view controller in 0.5 second.
     */
    static func RedirectToSignIn() {
        let appDelegate = UIApplication.sharedApplication().delegate
        
        UIView.transitionWithView(((appDelegate?.window)!)!,
                                  duration: NSTimeInterval(0.5),
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: { () -> Void in
                                    let previoudAnimationState = UIView.areAnimationsEnabled()
                                    appDelegate?.window!!.rootViewController = UIStoryboard(name: "SignIn",
                                                                                            bundle: nil).instantiateInitialViewController()
                                    UIView.setAnimationsEnabled(previoudAnimationState)
                                  },
                                  completion: nil)
    }
    
    /**
     Logout current user and navigation back to login view controller.
     */
    static func LogOut() {
        Helper.RedirectToSignIn()
        User.logOut()
    }
    
    // Popup an UIAlertController for showing information
    static func PopupInformationBox (controller: UIViewController, boxTitle: String?, message: String, block: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: boxTitle, message: message, preferredStyle: .Alert)
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: block))
        
        // Present alert controller
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Popup an UIAlertController for Yes/No selction
    static func PopupConfirmationBox (controller: UIViewController, boxTitle: String?, message: String, cancelBlock: ((UIAlertAction) -> Void)? = nil, confirmBlock: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: boxTitle, message: message, preferredStyle: .Alert)
        
        // Add a dismiss button to dismiss the popup alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelBlock))
        alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: confirmBlock))
        
        // Present alert controller
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func PopupInputBox (controller: UIViewController, boxTitle: String?, message: String, numberOfFileds: Int, textValues: [[String: String?]], WithBlock block: (inputValues: [String?]) -> Void) {
        let alert = UIAlertController(title: boxTitle, message: message, preferredStyle: .Alert)
        
        // Add an input text field
        
        for index in 0..<numberOfFileds {
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Set initial
                if let originalValue = textValues[index]["originalValue"] {
                    textField.text = originalValue
                }
                if let placeHolder = textValues[index]["placeHolder"] {
                    textField.placeholder = placeHolder

                }
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
