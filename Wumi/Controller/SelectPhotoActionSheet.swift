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

    var delegate: PIKAImageCropViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        self.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
            self.openPhotoLibrary()
        }))
        
        self.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    }
    
    // Open Camera to take a photo
    func openCamera() {
        // Check whether camera device is available
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            Helper.PopupErrorAlert(self, errorMessage: "Camera device is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        if let parentViewController = self.delegate as? UIViewController {
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
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = ["\(kUTTypeImage)"]
        
        if let parentViewController = self.delegate as? UIViewController {
            parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}

extension SelectPhotoActionSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            
            let imageCropper = PIKAImageCropViewController()
            
            imageCropper.image = image
            imageCropper.cropType = .Rect
            let cropperWidth = picker.view.bounds.width
            imageCropper.cropRectSize = CGSize(width: cropperWidth, height: cropperWidth / CGFloat(Constants.General.Size.AvatarImage.WidthHeightRatio))
            imageCropper.backgroundColor = Constants.General.Color.BackgroundColor
            imageCropper.themeColor = Constants.General.Color.ThemeColor
            imageCropper.titleColor = Constants.General.Color.TitleColor
            imageCropper.maskColor = Constants.General.Color.DarkMaskColor
            imageCropper.delegate = self.delegate
            
            if let parentViewController = self.delegate as? UIViewController {
                parentViewController.presentViewController(imageCropper, animated: true, completion: nil)
            }
        }
    }
}