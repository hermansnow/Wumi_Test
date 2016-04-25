//
//  PIKAImageCropViewController.swift
//  PIKAImagePicker
//
//  Created by Zhe Cheng on 4/18/16.
//  Copyright © 2016 Zhe Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices

public enum CropType {
    case Rect, Circle
}

class PIKAImageCropViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var actionBar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    lazy private var imageContainner = UIImageView()
    lazy private var cropMaskView = UIView()
    lazy private var imagePicker = UIImagePickerController()
    lazy private var cropRect: CGRect = CGRectZero
    
    var cropType: CropType = .Rect
    var cropRectSize: CGSize = CGSizeZero
    var cropCircleRadius: CGFloat = 0.0
    
    var delegate: PIKAImageCropViewControllerDelegate?
    
    static let TitleColor = UIColor.whiteColor()
    static let BackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    static let ThemeColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
    
    var image: UIImage? {
        didSet {
            if self.image != nil {
                if self.saveButton != nil {
                    self.saveButton.enabled = true
                    self.saveButton.tintColor = PIKAImageCropViewController.TitleColor
                }
                
                if self.image?.size != oldValue?.size {
                    self.imageContainner.image = image
                    self.imageContainner.sizeToFit()
                }
            }
            else {
                if self.saveButton != nil {
                    self.saveButton.enabled = false
                    self.saveButton.tintColor = PIKAImageCropViewController.BackgroundColor
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        if let view = UINib(nibName: "PIKAImageCropView", bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            view.frame = self.view.frame
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = PIKAImageCropViewController.BackgroundColor
        
        self.actionBar.barTintColor = PIKAImageCropViewController.ThemeColor
        self.actionBar.tintColor = PIKAImageCropViewController.TitleColor
        if self.image == nil {
            self.saveButton.enabled = false
            self.saveButton.tintColor = PIKAImageCropViewController.BackgroundColor
        }
        
        self.libraryButton.tintColor = PIKAImageCropViewController.TitleColor
        self.libraryButton.backgroundColor = PIKAImageCropViewController.ThemeColor
        
        self.cameraButton.tintColor = PIKAImageCropViewController.TitleColor
        self.cameraButton.backgroundColor = PIKAImageCropViewController.ThemeColor
        
        self.imageContainner.contentMode = .ScaleAspectFill
        
        self.scrollView.addSubview(imageContainner)
        self.view.addSubview(self.cropMaskView)
        
        // Add gesture recognizers
        self.cropMaskView.addGestureRecognizer(scrollView.panGestureRecognizer)
        self.cropMaskView.addGestureRecognizer(scrollView.pinchGestureRecognizer!)
        
        // Set image picker
        self.imagePicker.navigationBar.barTintColor = PIKAImageCropViewController.ThemeColor
        self.imagePicker.navigationBar.tintColor = PIKAImageCropViewController.TitleColor
        self.imagePicker.navigationBar.titleTextAttributes = [
             NSForegroundColorAttributeName: PIKAImageCropViewController.TitleColor // Title color
        ]
        self.imagePicker.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showImage(fitSize: true, animated: false)
        
        self.showCropMask()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    private func showImage(fitSize fitSize: Bool, animated: Bool) {
        guard self.imageContainner.image != nil else { return }
        
        if (fitSize) {
            let width = self.scrollView.frame.size.width
            let height = self.imageContainner.frame.size.height / self.imageContainner.frame.size.width * width
            
            self.imageContainner.frame.size = CGSize(width: width, height: height)
        }
        
        var offx = self.scrollView.frame.size.width > self.imageContainner.frame.width ? (scrollView.frame.size.width - self.imageContainner.frame.width) / 2 : 0
        offx = offx > self.cropRect.origin.x ? offx: self.cropRect.origin.x
        var offy = self.scrollView.frame.size.height > self.imageContainner.frame.height ? (scrollView.frame.size.height - self.imageContainner.frame.height) / 2 : 0
        offy = offy > self.cropRect.origin.y ? offy: self.cropRect.origin.y
        
        
        if animated {
            UIView.animateWithDuration(0.3) {
                self.scrollView.contentInset = UIEdgeInsets(top: offy, left: offx, bottom: offy, right: offx)
            }
        }
        else {
            self.scrollView.contentInset = UIEdgeInsets(top: offy, left: offx, bottom: offy, right: offx)
        }
        self.scrollView.contentSize = self.imageContainner.frame.size
    }
    
    private func showCropMask() {
        // Initialize mask layercropMaskView
        self.cropMaskView.frame = self.contentView.frame
        self.cropMaskView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        // Add crop view
        if let cropLayer = self.createCropLayer() {
            self.cropMaskView.layer.mask = cropLayer
        }
    }
    
    private func createCropLayer() -> CALayer? {
        let path = UIBezierPath(rect: self.contentView.bounds)
        
        switch self.cropType {
        case .Rect:
            let width = self.cropRectSize.width > self.contentView.bounds.size.width ? self.contentView.bounds.size.width: self.cropRectSize.width
            let height = self.cropRectSize.height > self.contentView.bounds.size.height ? self.contentView.bounds.size.height: self.cropRectSize.height
            
            self.cropRect = CGRect(x: (self.contentView.bounds.size.width - width) / 2,
                                   y: (self.contentView.bounds.size.height - height) / 2,
                                   width: width,
                                   height: height)
            
            path.appendPath(UIBezierPath(rect: self.cropRect).bezierPathByReversingPath())
            
        case .Circle:
            print(self.view.bounds)
            var diameter = self.cropCircleRadius * 2 > self.contentView.bounds.size.width ? self.contentView.bounds.size.width: self.cropCircleRadius * 2
            diameter = diameter > self.contentView.bounds.size.height ? self.contentView.bounds.size.height: diameter
            
            self.cropRect = CGRect(x: (self.contentView.bounds.size.width - diameter) / 2,
                                   y: (self.contentView.bounds.size.height - diameter) / 2,
                                   width: diameter,
                                   height: diameter)
            
            path.appendPath(UIBezierPath(ovalInRect: self.cropRect).bezierPathByReversingPath())
        }
        
        let shape = CAShapeLayer()
        shape.path = path.CGPath
        
        return shape
    }
    
    @IBAction func save(sender: AnyObject) {
        guard let delegate = self.delegate else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var visibleImageRect = self.imageContainner.convertRect(self.cropRect, fromView: self.cropMaskView)
            let ratioX = self.image!.size.width / self.imageContainner.displayedImageBounds().width
            let ratioY = self.image!.size.height / self.imageContainner.displayedImageBounds().height
            visibleImageRect.origin.x *= ratioY
            visibleImageRect.size.width *= ratioX
            visibleImageRect.origin.y *= ratioX
            visibleImageRect.size.height *= ratioY
            
            var croppedImage: UIImage?
            if let image = self.image, cgImage = image.CGImage, imageRef = CGImageCreateWithImageInRect(cgImage, visibleImageRect) {
                croppedImage = UIImage(CGImage: imageRef)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                delegate.imageCropViewController(self, didFinishCropImageWithImage: croppedImage)
            })
            
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Open Camera to take a photo
    @IBAction func openCamera() {
        // Check whether camera device is available
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            let alert = UIAlertController(title: "Failed", message: "Camera device is not available.", preferredStyle: .Alert)
            
            // Add a dismiss button to dismiss the popup alert
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            // Present alert controller
            self.presentViewController(alert, animated: true, completion: nil)

            return
        }
        
        self.imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Open local photo library
    @IBAction func openPhotoLibrary() {
        // Check whether photo library is available
        guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
            let alert = UIAlertController(title: "Failed", message: "Photo library is not available.", preferredStyle: .Alert)
            
            // Add a dismiss button to dismiss the popup alert
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            // Present alert controller
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        self.imagePicker.sourceType = .PhotoLibrary
        self.imagePicker.mediaTypes = ["\(kUTTypeImage)"]
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

extension PIKAImageCropViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageContainner
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.showImage(fitSize: false, animated: true)
    }
}

extension PIKAImageCropViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            
            self.image = image
            
            self.scrollView.zoomScale = 1.0
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            
            self.showImage(fitSize: true, animated: false)
        }
    }
}

protocol PIKAImageCropViewControllerDelegate {
    func imageCropViewController(cropVC: PIKAImageCropViewController, didFinishCropImageWithImage image: UIImage?);
}

extension UIImageView {
    
    func displayedImageBounds() -> CGRect {
        
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
        return CGRectMake(0,topLeftY, boundsWidth,height)
    }
}
