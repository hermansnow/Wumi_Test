//
//  NewPostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {

    @IBOutlet weak var composePostView: ComposePostView!
    
    lazy var nextButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize subject text field
        self.composePostView.subjectTextField.backgroundColor = Constants.General.Color.BackgroundColor
        
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
            keyboardRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        self.composePostView.contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
    }
    
    // Resize text view when dismissing the keyboard
    func keyboardWillHiden(notification: NSNotification) {
        self.composePostView.contentTextView.contentInset = UIEdgeInsetsZero
    }
}

extension NewPostViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let postView = textView as? PostTextView, remainingCharaters = postView.checkRemainingCharacters() else { return true }
        
        return text.characters.count - range.length <= remainingCharaters
    }
}

extension NewPostViewController: UITextFieldDelegate { }