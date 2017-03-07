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
    // View for composing new post.
    private lazy var composePostView: ComposePostView = ComposePostView()
    /// Height constraint of composePostView.
    private lazy var composePostViewHeightConstraint = NSLayoutConstraint()
    /// Array of assets selected from library.
    private lazy var selectedAssets = [PHAsset]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        let nextButton = UIBarButtonItem(title: "Next",
                                         style: .Plain,
                                         target: self,
                                         action: #selector(self.next))
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                          target: self,
                                          action: #selector(self.dismiss))
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = nextButton
        
        // Add components
        self.addComposePostView()
        
        // Setup norification observer
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardWillShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardWillHiden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.reachabilityChanged(_:)),
                                                         name: Constants.General.ReachabilityChangedNotification,
                                                         object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkReachability()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dismissReachabilityError()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let postCategoryTableViewController = segue.destinationViewController as? PostCategoryTableViewController where segue.identifier == "chooseCategory" {
            let post = Post()
            post.title = self.composePostView.subject
            post.content = self.composePostView.content
            post.attachedImages = self.composePostView.selectedImages
            postCategoryTableViewController.post = post
        }
    }
    
    // MARK: UI functions
    
    /**
     Add view for composing post.
     */
    private func addComposePostView() {
        // Add to view
        self.view.addSubview(self.composePostView)
        
        // Initialize subject text field
        self.composePostView.subjectBackgroundColor = Constants.General.Color.BackgroundColor
        self.composePostView.allowsContentEditingTextAttributes = true
        
        // Add Constraints
        self.composePostView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.composePostView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.composePostView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.composePostViewHeightConstraint = NSLayoutConstraint(item: self.composePostView,
                                                                  attribute: .Height,
                                                                  relatedBy: .Equal,
                                                                  toItem: nil,
                                                                  attribute: .NotAnAttribute,
                                                                  multiplier: 1,
                                                                  constant: self.view.bounds.size.height
                                                                            - (self.navigationController?.navigationBar.frame.size.height)!
                                                                            - UIApplication.sharedApplication().statusBarFrame.size.height)
        self.composePostViewHeightConstraint.active = true
        self.composePostView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add delegate
        self.composePostView.delegate = self
    }
    
    // MARK: Action
    
    /**
     Dismiss current view controller with animation.
     */
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Action when clicking Next navigation button.
     */
    func next() {
        guard self.composePostView.content.characters.count > 0 else {
            ErrorHandler.popupErrorAlert(self, errorMessage: "Cannot send blank post")
            return
        }
        
        self.performSegueWithIdentifier("chooseCategory", sender: self)
    }
    
    /**
     Resize text view when showing the keyboard.
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
     */
    func keyboardWillShown(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        
        self.composePostView.layoutIfNeeded()
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.composePostViewHeightConstraint.constant = self.view.bounds.height - keyboardRect.size.height
            self.composePostView.layoutIfNeeded()
        })
    }
    
    /**
     Resize text view when dismissing the keyboard.
     
     - Parameters:
        - notification: NSNotification triggers this action with user info.
    */
    func keyboardWillHiden(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo as? Dictionary<String, NSValue>,
            keyboardDurVal = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        
        // Get keyboard animation duration
        var keyboardDuration: NSTimeInterval = 0.0
        keyboardDurVal.getValue(&keyboardDuration)
        
        self.composePostView.layoutIfNeeded()
        UIView.animateWithDuration(keyboardDuration, animations: { () -> Void in
            self.composePostViewHeightConstraint.constant = self.view.bounds.size.height
            self.composePostView.layoutIfNeeded()
        })
    }
}

// MARK: ComposePostView delegate

extension NewPostViewController: ComposePostViewDelegate {
    /**
     Click add button to select a image from library.
     */
    func selectImage() {
        let picker = SelectPhotoActionSheet()
        picker.selectedAssets.addObjectsFromArray(self.selectedAssets)
        picker.multipleSelection = true
        picker.maximumNumberOfAssets = Constants.Post.maximumImages
        picker.delegate = self
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let postView = textView as? PlaceholderTextView, remainingCharaters = postView.checkRemainingCharacters() else { return true }
        
        return text.characters.count - range.length <= remainingCharaters
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layoutIfNeeded() // Fix textfield bounce glitch issue in iOS 9+
    }
}

// MARK: SelectedThumbnailImageView delegate

extension NewPostViewController: SelectedThumbnailImageViewDelegate {
    /**
     Remove an image view from attached images view.
     
     - Parameters:
        - imageView: image view to be removed.
     */
    func removeImage(imageView: SelectedThumbnailImageView) {
        // Remove selected data
        self.composePostView.removeImage(imageView)
        if let image = imageView.image, index = self.composePostView.selectedImages.indexOf(image) {
            self.selectedAssets.removeAtIndex(index)
        }
        
        // Enable add image button if it is disabled
        if self.composePostView.enableAddImage == false && self.composePostView.selectedImages.count < Constants.Post.maximumImages  {
            self.composePostView.enableAddImage = true
        }
    }
    
    /**
     Show image for viewing.
     
     - Parameters:
        - imageView: image view to be displayed.
     */
    func showImage(imageView: SelectedThumbnailImageView) {
        guard let image = imageView.image, index = self.composePostView.selectedImages.indexOf(image) else { return }
        
        let imagePageVC = ImageFullScreenViewController()
        imagePageVC.images = self.composePostView.selectedImages
        imagePageVC.currentIndex = index
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
            self.composePostView.enableAddImage = false
        }
    }
}
