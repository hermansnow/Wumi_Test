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
    @IBOutlet weak var postContentTextView: UITextView!
    
    lazy var currentUser = User.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subjectTextField.backgroundColor = Constants.General.Color.BackgroundColor
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