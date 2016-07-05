//
//  NewPostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CTAssetsPickerController

class NewPostViewController: UIViewController {

    lazy var composePostView: ComposePostView = ComposePostView()
    lazy var nextButton = UIBarButtonItem()
    private var heightConstraint = NSLayoutConstraint()
    
    private var selectedAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.composePostView)
        
        // Initialize subject text field
        self.composePostView.subjectTextField.backgroundColor = Constants.General.Color.BackgroundColor
        self.composePostView.contentTextView.allowsEditingTextAttributes = true
        
        // Add delegate
        self.composePostView.delegate = self
        
        // Initialize navigation bar
        self.nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(next(_:)))
        self.navigationItem.rightBarButtonItem = self.nextButton
        
        // Setup keyboard Listener
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(keyboardWillShown(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(keyboardWillHiden(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        // Add Constraints
        self.composePostView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.composePostView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.composePostView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.heightConstraint = NSLayoutConstraint(item: self.composePostView,
                                                   attribute: .Height,
                                                   relatedBy: .Equal,
                                                   toItem: nil,
                                                   attribute: .NotAnAttribute,
                                                   multiplier: 1,
                                                   constant: self.view.bounds.size.height
                                                    - (self.navigationController?.navigationBar.frame.size.height)!
                                                    - UIApplication.sharedApplication().statusBarFrame.size.height)
        self.composePostView.translatesAutoresizingMaskIntoConstraints = false
        self.heightConstraint.active = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postCategoryTableViewController = segue.destinationViewController as? PostCategoryTableViewController where segue.identifier == "chooseCategory" {
            let post = Post()
            post.title = self.composePostView.title
            post.content = self.composePostView.content
            post.attachedImages = self.composePostView.selectedImages
            postCategoryTableViewController.post = post
        }
    }
    
    // MARK: Action
    
    func next(sender: AnyObject) {
        guard self.composePostView.content.characters.count > 0 else {
            Helper.PopupErrorAlert(self, errorMessage: "Cannot send blank post")
            return
        }
        
        self.performSegueWithIdentifier("chooseCategory", sender: self)
    }
    
    // Resize text view when showing the keyboard
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        
        self.composePostView.layoutIfNeeded()
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.heightConstraint.constant = self.view.bounds.height - keyboardRect.size.height
            self.composePostView.layoutIfNeeded()
        })
    }
    
    // Resize text view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        
        self.composePostView.layoutIfNeeded()
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.heightConstraint.constant = self.view.bounds.size.height
            self.composePostView.layoutIfNeeded()
        })
    }
}

// MARK: ComposePostView delegate

extension NewPostViewController: ComposePostViewDelegate {
    func selectImage() {
        let picker = SelectPhotoActionSheet()
        picker.selectedAssets.addObjectsFromArray(self.selectedAssets)
        picker.multipleSelection = true
        picker.maximumNumberOfAssets = Constants.Post.maximumImages
        picker.delegate = self
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let postView = textView as? PostTextView, remainingCharaters = postView.checkRemainingCharacters() else { return true }
        
        return text.characters.count - range.length <= remainingCharaters
    }
}

// MARK: SelectedThumbnailImageView delegate

extension NewPostViewController: SelectedThumbnailImageViewDelegate {
    func removeImage(imageView: SelectedThumbnailImageView) {
        imageView.removeFromSuperview()
        
        // Enable add image button if it is disabled
        if self.composePostView.addImageButton.enabled == false {
            self.composePostView.addImageButton.enabled = true
        }
    }
    
    func showImage(imageView: SelectedThumbnailImageView) {
        guard let image = imageView.image, index = self.composePostView.selectedImages.indexOf(image),
            imagePageVC = storyboard!.instantiateViewControllerWithIdentifier("ImagePageViewController") as? ImagePageViewController else { return }
        
        imagePageVC.images = self.composePostView.selectedImages
        imagePageVC.startIndex = index
        
        imagePageVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(imagePageVC, animated: true, completion: nil)
    }
}

// MARK: SelectPhotoActionSheet delegate

extension NewPostViewController: SelectPhotoActionSheetDelegate {
    func selectPhotoActionSheet(controller: SelectPhotoActionSheet, didFinishePickingPhotos images: [UIImage], assets: [PHAsset]?, sourceType: UIImagePickerControllerSourceType) {
        guard let results = assets else { return }
        
        // Selecting from library should return a full list of assets, move current selected assets
        if sourceType == .PhotoLibrary {
            self.composePostView.removeAllImages()
            self.selectedAssets.removeAll()
        }
        
        for index in 0...images.count - 1 {
            guard let image = images[safe: index], asset = results[safe: index] where !self.selectedAssets.contains(asset) else { return }
            
            self.composePostView.insertImage(image)
            self.selectedAssets.append(asset)
        }
        
        // Disable add image button if reaching maximum
        if self.composePostView.selectedImages.count == Constants.Post.maximumImages {
            self.composePostView.addImageButton.enabled = false
        }
    }
}