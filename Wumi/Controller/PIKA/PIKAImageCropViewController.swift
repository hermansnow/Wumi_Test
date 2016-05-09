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
    
    lazy private var imageContainner = UIImageView()
    lazy private var cropMaskView = UIView()
    lazy private var cropRect: CGRect = CGRectZero
    
    var cropType: CropType = .Rect
    var cropRectSize: CGSize = CGSizeZero
    var cropCircleRadius: CGFloat = 0.0
    var thumbnailSize: CGSize?
    
    var delegate: PIKAImageCropViewControllerDelegate?
    
    var titleColor = UIColor.whiteColor()
    var backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    var themeColor = UIColor.cyanColor()
    var maskColor = UIColor(white: 0.0, alpha: 0.5)
    
    var image: UIImage? {
        didSet {
            if self.image != nil {
                if self.saveButton != nil {
                    self.saveButton.enabled = true
                    self.saveButton.tintColor = self.titleColor
                }
                
                if self.image?.size != oldValue?.size {
                    self.imageContainner.image = image
                    self.imageContainner.sizeToFit()
                }
            }
            else {
                if self.saveButton != nil {
                    self.saveButton.enabled = false
                    self.saveButton.tintColor = self.backgroundColor
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
        self.scrollView.backgroundColor = self.backgroundColor
        
        self.actionBar.barTintColor = self.themeColor
        self.actionBar.tintColor = self.titleColor
        self.actionBar.translucent = false
        if self.image == nil {
            self.saveButton.enabled = false
            self.saveButton.tintColor = self.backgroundColor
        }
        
        self.imageContainner.contentMode = .ScaleAspectFill
        
        // Add gesture recognizers
        self.cropMaskView.addGestureRecognizer(scrollView.panGestureRecognizer)
        self.cropMaskView.addGestureRecognizer(scrollView.pinchGestureRecognizer!)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(reset(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.cropMaskView.addGestureRecognizer(doubleTapGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showCropMask()
        self.showImage(fitSize: true, center: true,animated: false)
        
        if !self.scrollView.subviews.contains(self.imageContainner) {
            self.scrollView.addSubview(imageContainner)
        }
        if !self.view.subviews.contains(self.cropMaskView) {
            self.view.addSubview(self.cropMaskView)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    private func showImage(fitSize fitSize: Bool, center: Bool, animated: Bool) {
        guard self.imageContainner.image != nil else { return }
        
        // Resize the image to fit the size of scrollview
        if fitSize {
            let width = self.scrollView.frame.size.width
            let height = self.imageContainner.frame.size.height / self.imageContainner.frame.size.width * width
            
            self.imageContainner.frame.size = CGSize(width: width, height: height)
        }
        
        // Add inset so that we can move to reach the top/bottom of image
        var insetX = self.scrollView.frame.size.width > self.imageContainner.frame.width ? (scrollView.frame.size.width - self.imageContainner.frame.width) / 2 : 0
        insetX = insetX > self.cropRect.origin.x ? insetX: self.cropRect.origin.x
        var insetY = self.scrollView.frame.size.height > self.imageContainner.frame.height ? (scrollView.frame.size.height - self.imageContainner.frame.height) / 2 : 0
        insetY = insetY > self.cropRect.origin.y ? insetY: self.cropRect.origin.y
        
        if animated {
            UIView.animateWithDuration(0.3) {
                self.scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
            }
        }
        else {
            self.scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        }
        
        self.scrollView.contentSize = self.imageContainner.frame.size
        
        // Change offset to move image to center
        if center {
            let offY = self.imageContainner.bounds.size.height > self.cropRect.size.height ? insetY - (self.imageContainner.bounds.size.height - self.cropRect.size.height) / 2 : insetY
            let offX = self.imageContainner.bounds.size.width > self.cropRect.size.width ? insetY - (self.imageContainner.bounds.size.width - self.cropRect.size.width) / 2 : insetX
            self.scrollView.contentOffset = CGPoint(x: -offX, y: -offY)
        }
    }
    
    private func showCropMask() {
        // Initialize mask layercropMaskView
        self.cropMaskView.frame = self.contentView.frame
        self.cropMaskView.backgroundColor = self.maskColor
        self.cropMaskView.layer.borderWidth = 1.0
        self.cropMaskView.layer.borderColor = self.maskColor.CGColor
        
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
    
    // MARK: Actions
    
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
            var thumbnail: UIImage?
            if let image = self.image, cgImage = image.CGImage, imageRef = CGImageCreateWithImageInRect(cgImage, visibleImageRect) {
                croppedImage = UIImage(CGImage: imageRef)
                
                // Generate thumbnail if needed
                if let thumbnailSize = self.thumbnailSize {
                    let rect = CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height)
                    UIGraphicsBeginImageContext(thumbnailSize)
                    croppedImage?.drawInRect(rect)
                    thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                var info = [String: UIImage]()
                
                info["OriginalImage"] = self.image
                info["CroppedImage"] = croppedImage
                info["Thumbnail"] = thumbnail
                delegate.imageCropViewController(self, didFinishCropImageWithInfo: info)
            })
            
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reset(sender: UITapGestureRecognizer) {
        self.scrollView.zoomScale = 1.0
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        self.showImage(fitSize: true, center: true, animated: false)
    }
}

extension PIKAImageCropViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageContainner
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.showImage(fitSize: false, center: false, animated: true)
    }
}

protocol PIKAImageCropViewControllerDelegate {
    func imageCropViewController(cropVC: PIKAImageCropViewController, didFinishCropImageWithInfo info: [String: UIImage?])
}

extension UIImageView {
    
    // Return bounds of displayed image
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
    
    // Return image scale factor
    func imageScaleFactor() -> CGFloat {
        guard let image = self.image else { return 1.0 }
        
        let widthScale = self.bounds.size.width / image.size.width
        let heightScale = self.bounds.size.height / image.size.height
        
        if (self.contentMode == .ScaleToFill) {
            return widthScale == heightScale ? widthScale : 0
        }
        if (self.contentMode == .ScaleAspectFit) {
            return min(widthScale, heightScale)
        }
        if (self.contentMode == .ScaleAspectFill) {
            return max(widthScale, heightScale)
        }
        return 1.0;
    }
}
