//
//  SelectPhotoActionSheet.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices
import CTAssetsPickerController

class SelectPhotoActionSheet: UIAlertController {

    var delegate: SelectPhotoActionSheetDelegate?
    var maximumNumberOfAssets = 1 // Maximum number of assets can be selected
    var multipleSelection = false // Whether support multiple selection
    var cropImage = false // Whether allow end-user to crop image from selection
    var selectedAssets = NSMutableArray() // Array of selected assets
    var sourceType: UIImagePickerControllerSourceType? // Source type of images returns
    
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
    private func openCamera() {
        guard let parentViewController = self.delegate as? UIViewController else { return }
        self.sourceType = .Camera
        
        // Check whether camera device is available
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            Helper.PopupErrorAlert(self, errorMessage: "Camera device is not available.", dismissButtonTitle: "OK")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Open local photo library
    private func openPhotoLibrary() {
        guard let parentViewController = self.delegate as? UIViewController else { return }
        self.sourceType = .PhotoLibrary
        
        // Check whether photo library is available
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            Helper.PopupErrorAlert(self, errorMessage: "Photo library is not available.", dismissButtonTitle: "OK")
            return
        }
        
        if self.multipleSelection {
            let imagePicker = CTAssetsPickerController()
            
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue) // Only show images
            imagePicker.alwaysEnableDoneButton = true
            imagePicker.assetsFetchOptions = options
            imagePicker.selectedAssets = self.selectedAssets
            imagePicker.showsEmptyAlbums = false
            imagePicker.showsNumberOfAssets = true
            imagePicker.showsSelectionIndex = true
            imagePicker.doneButtonTitle = "Select"
            imagePicker.modalPresentationStyle = .FormSheet
            imagePicker.delegate = self
            
            parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.mediaTypes = ["\(kUTTypeImage)"]
            
            parentViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: UIImagePicker delegate

extension SelectPhotoActionSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
                parentViewController = self.delegate as? UIViewController,
                delegate = self.delegate,
                sourceType = self.sourceType else { return }
            
            if self.cropImage {
                let imageCropper = PIKAImageCropViewController()
            
                imageCropper.image = image
                imageCropper.cropType = .Rect
                let cropperWidth = picker.view.bounds.width
                imageCropper.cropRectSize = CGSize(width: cropperWidth, height: cropperWidth / CGFloat(Constants.General.Size.AvatarImage.WidthHeightRatio))
                imageCropper.backgroundColor = Constants.General.Color.BackgroundColor
                imageCropper.themeColor = Constants.General.Color.ThemeColor
                imageCropper.titleColor = Constants.General.Color.TitleColor
                imageCropper.maskColor = Constants.General.Color.DarkMaskColor
                imageCropper.delegate = self
                
                parentViewController.presentViewController(imageCropper, animated: true, completion: nil)
            }
            else {
                if sourceType == .Camera {
                    image.saveToLibrary(album: nil) { (result, error) in
                        guard let asset = result where error == nil else { return }
                        
                        delegate.selectPhotoActionSheet(self, didFinishePickingPhotos: [image], assets: [asset], sourceType: sourceType)
                    }
                }
                else {
                    delegate.selectPhotoActionSheet(self, didFinishePickingPhotos: [image], assets: nil, sourceType: sourceType)
                }
            }
            
        }
    }
}

// MARK: PIKAImageCropViewControllerDelegate delegate

extension SelectPhotoActionSheet: PIKAImageCropViewControllerDelegate {
    func imageCropViewController(cropVC: PIKAImageCropViewController, didFinishCropImageWithInfo info: [String: UIImage?]) {
        cropVC.dismissViewControllerAnimated(true) { () -> Void in
            guard let value = info["CroppedImage"],
                croppedImage = value,
                delegate = self.delegate,
                sourceType = self.sourceType else { return }
            
            if sourceType == .Camera {
                croppedImage.saveToLibrary(album: nil) { (result, error) in
                    guard let asset = result where error == nil else { return }
                    
                    delegate.selectPhotoActionSheet(self, didFinishePickingPhotos: [croppedImage], assets: [asset], sourceType: sourceType)
                }
            }
            else {
                delegate.selectPhotoActionSheet(self, didFinishePickingPhotos: [croppedImage], assets: nil, sourceType: sourceType)
            }
        }
    }
}

// MARK: CTAssetsPickerControllerDelegate delegate

extension SelectPhotoActionSheet: CTAssetsPickerControllerDelegate {
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: PHAsset!) -> Bool {
        return picker.selectedAssets.count < self.maximumNumberOfAssets
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: {
            guard let delegate = self.delegate, results = assets as? [PHAsset], sourceType = self.sourceType else { return }
            
            let assetManager = PHImageManager.defaultManager()
            var images = [UIImage]()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                for asset in results {
                    let options = PHImageRequestOptions()
                    options.synchronous = true
                    assetManager.requestImageForAsset(asset, targetSize: CGSize(width: 600, height: 400), contentMode: .AspectFit, options: options, resultHandler: { (result, info) in
                        guard let image = result else { return }
                        images.append(image)
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    delegate.selectPhotoActionSheet(self, didFinishePickingPhotos: images, assets: results, sourceType: sourceType)
                })
            })
        })
    }
}

// MARK: SelectPhotoActionSheetDelegate

@objc protocol SelectPhotoActionSheetDelegate {
    func selectPhotoActionSheet(controller: SelectPhotoActionSheet, didFinishePickingPhotos images: [UIImage], assets: [PHAsset]?, sourceType: UIImagePickerControllerSourceType)
}