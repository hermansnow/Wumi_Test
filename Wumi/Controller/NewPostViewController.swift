//
//  NewPostViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {

    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var postContentTextView: PostTextView!
    
    lazy var currentUser = User.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subjectTextField.backgroundColor = Constants.General.Color.BackgroundColor
        
        self.postContentTextView.delegate = self
    }
    
    // MARK: Action
    
    @IBAction func sendPost(sender: AnyObject) {
        Post.sendNewPost(author: self.currentUser,
            title: self.subjectTextField.text,
            content: self.postContentTextView.text) { (success, error) -> Void in
                guard success && error == nil else {
                    print("\(error)")
                    return
                }
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

extension NewPostViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let postView = textView as? PostTextView else { return false }
        
        return text.characters.count - range.length <= postView.checkRemainingCharacters()
    }
}