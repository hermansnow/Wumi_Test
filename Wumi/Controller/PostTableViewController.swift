//
//  PostTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {

    var currentUser = User.currentUser()
    
    lazy var posts = [Post]()
    var updatedAtDateFormatter = NSDateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Register nib
        self.tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        
        // Initialize tableview
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.updatedAtDateFormatter.dateFormat = "hh:mm"
        
        // Load posts
        self.loadPosts()
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        guard let post = self.posts[safe: indexPath.row] else { return cell }

        cell.titleLabel.text = post.title
        cell.contentLabel.text = post.content
        cell.timeStampLabel.text = self.updatedAtDateFormatter.stringFromDate(post.updatedAt)
        
        post.author?.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            guard let user = result as? User where error == nil else { return }
            
            cell.authorView.detailLabel.text = user.name
            
            user.loadAvatar { (imageResult, imageError) -> Void in
                guard let image = imageResult where imageError == nil else { return }
                cell.authorView.avatarImageView.image = image
            }
        }

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Actions
    
    // MARK: Help function
    private func loadPosts() {
        self.currentUser.loadPosts { (results, error) -> Void in
            guard let posts = results as? [Post] else { return }
            
            self.posts.insertContentsOf(posts, at: 0)
            
            self.tableView.reloadData()
        }
    }

}
