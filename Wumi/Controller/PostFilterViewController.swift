//
//  PostFilterViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostFilterViewController: UITableViewController {
    
    lazy var searchButton = UIBarButtonItem()
    
    lazy var categories = [PostCategory]()
    var selectedButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        self.searchButton = UIBarButtonItem(title: "Search", style: .Done, target: self, action: #selector(searchPost(_:)))
        self.navigationItem.rightBarButtonItem = self.searchButton
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Category"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCategoryCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            self.categoryCell(cell, forRowAtIndexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    private func categoryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let category = self.categories[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = category.name
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(Constants.General.Image.Check, forState: .Selected)
        checkButton.setImage(Constants.General.Image.Uncheck, forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(selectCategory(_:)), forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    // MARK: Action
    
    func selectCategory(sender: UIButton) {
        if !sender.selected {
            if let button = self.selectedButton {
                button.selected = false
            }
            self.selectedButton = sender
            sender.selected = true
        }
    }
    
    func searchPost(sender: AnyObject) {
        // Navigate back to home view controller
        guard let homeVC = self.navigationController?.viewControllers.filter({ $0 is HomeViewController }).first as? HomeViewController,
            button = self.selectedButton,
            category = self.categories[safe: button.tag] else { return }
        
        homeVC.category = category
        homeVC.needResearch = true
            
        self.navigationController?.popToViewController(homeVC, animated: true)
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
