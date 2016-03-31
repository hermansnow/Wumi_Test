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
        self.nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "next:")
        self.navigationItem.rightBarButtonItem = self.nextButton
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
            Helper.PopupErrorAlert(self, errorMessage: "Cannot send blank post", block: nil)
            return
        }
        
        self.performSegueWithIdentifier("chooseCategory", sender: self)
    }
}

extension NewPostViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let postView = textView as? PostTextView else { return false }
        
        return text.characters.count - range.length <= postView.checkRemainingCharacters()
    }
}

extension NewPostViewController: UITextFieldDelegate { }