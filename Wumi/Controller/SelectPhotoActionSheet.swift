//
//  SelectPhotoActionSheet.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices

class SelectPhotoActionSheet: UIAlertController {

    var delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?
    var launchViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
            self.openPhotoLibrary()
        }))
        
        addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    }
    
    // Open Camera to take a photo
    func openCamera() {
        // Check whether camera device is available
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            Helper.PopupErrorAlert(self, errorMessage: "Camera device is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self.delegate
        imagePicker.sourceType = .Camera
        imagePicker.mediaTypes = ["\(kUTTypePNG)"]
        
        if let parentViewController = self.launchViewController {
            parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Open local photo library
    func openPhotoLibrary() {
        // Check whether photo library is available
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            Helper.PopupErrorAlert(self, errorMessage: "Photo library is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self.delegate
        imagePicker.sourceType = .PhotoLibrary
        
        if let parentViewController = self.launchViewController {
            parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}
