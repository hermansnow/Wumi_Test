//
//  PostCategoryTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostCategoryTableViewController: UITableViewController {
    
    lazy var sendButton = UIBarButtonItem()
    
    var post = Post()
    lazy var currentUser = User.currentUser()
    lazy var categories = [PostCategory]()
    lazy var selectedCategories = [PostCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        self.sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: "sendPost:")
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        // Load categories
        self.loadPostCategories()
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCategoryCell", forIndexPath: indexPath)
        
        guard let category = self.categories[safe: indexPath.row] else { return cell }
        
        cell.textLabel!.text = category.name
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(Constants.General.Image.Check, forState: .Selected)
        checkButton.setImage(Constants.General.Image.Uncheck, forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: "selectCategory:", forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    // MARK: Action
    
    func selectCategory(sender: UIButton) {
        guard let category = self.categories[safe: sender.tag] else { return }
        
        if sender.selected {
            self.selectedCategories.removeObject(category)
            sender.selected = false
        }
        else {
            self.selectedCategories.append(category)
            sender.selected = true
        }
        
        print(self.selectedCategories)
    }
    
    func sendPost(sender: AnyObject) {
        Post.sendNewPost(author: self.currentUser,
            title: self.post.title,
            content: self.post.content,
            categories: self.selectedCategories) { (success, error) -> Void in
                guard success && error == nil else {
                    print("\(error)")
                    return
                }
                
                // Navigate back to post table view
                if let postTVC = self.navigationController?.viewControllers.filter({ $0 is PostTableViewController }).first {
                    self.navigationController?.popToViewController(postTVC, animated: true)
                }
        }
    }

    // MARK: Help function
    private func loadPostCategories() {
        PostCategory.loadCategories { (results, error) -> Void in
            guard let categories = results as? [PostCategory] where error == nil && categories.count > 0 else { return }
            
            self.categories = categories
            
            self.tableView.reloadData()
        }
    }
    
}