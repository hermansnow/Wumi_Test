//
//  PostFilterViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 8/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostFilterViewController: DataLoadingTableViewController {
    /// Current search filter.
    var searchFilter = PostSearchFilter()
    /// Filter view delegate:
    var delegate: PostFilterViewControllerDelegate?
    /// Array of post category.
    lazy var categories = [PostCategory]()
    /// Array of post area.
    lazy var areas = [Area]()
    /// UIButton for selected post category to be searched.
    var selectedCategoryButton: CheckButton?
    /// UIButton for selected post area to be searched.
    var selectedAreaButton: CheckButton?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        self.setupNavigationBar()
        
        // Load categories
        self.loadPostCategories()
        
        // Load search areas
        self.loadSearchAreas()
    }
    
    // MARK: UI functions
    
    /**
     Setup navigation bar.
     */
    func setupNavigationBar() {
        self.navigationItem.title = "Select Custom Filter"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search",
                                                                 style: .Done,
                                                                 target: self,
                                                                 action: #selector(self.search))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                                                target: self,
                                                                action: #selector(self.dismiss))
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.categories.count
        case 1:
            return self.areas.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Category"
        case 1:
            return "Area"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeueCell = tableView.dequeueReusableCellWithIdentifier("PostFilterCell") {
            cell = dequeueCell
        }
        else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "PostFilterCell")
        }
        
        switch indexPath.section {
        case 0:
            self.setupCategoryCell(cell, forRowAtIndexPath: indexPath)
        case 1:
            self.setupAreaCell(cell, forRowAtIndexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    /**
     Set up a post category filter cell.
     
     - Parameters:
        - cell: tableview cell to be set up.
        - forRowAtIndexPath: cell's index path.
     */
    func setupCategoryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let category = self.categories[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = category.name
        
        // Add accessory button
        let checkButton = CheckButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.indexPath = indexPath
        checkButton.delegate = self
        if let selectedCategory = self.searchFilter.category where category == selectedCategory {
            checkButton.selected = true
            self.selectedCategoryButton = checkButton
        }
        else {
            checkButton.selected = false
        }
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    /**
     Set up an area category filter cell.
     
     - Parameters:
        - cell: tableview cell to be set up.
        - forRowAtIndexPath: cell's index path.
     */
    func setupAreaCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let area = self.areas[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = area.name
        
        // Add accessory button
        let checkButton = CheckButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.indexPath = indexPath
        checkButton.delegate = self
        if let selectedArea = self.searchFilter.area where area == selectedArea {
            checkButton.selected = true
            self.selectedAreaButton = checkButton
        }
        else {
            checkButton.selected = false
        }
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    // MARK: Action
    
    /**
     Action when selecting a category by clicking its accessary button.
     
     - Parameters:
        - sender: UIButton selected.
     */
    func selectCategory(sender: CheckButton) {
        if !sender.selected {
            if let button = self.selectedCategoryButton {
                button.selected = false
            }
            sender.selected = true
            self.selectedCategoryButton = sender
        }
        else {
            sender.selected = false
            self.selectedCategoryButton = nil
        }
    }
    
    /**
     Action when selecting an area by clicking its accessary button.
     
     - Parameters:
        - sender: UIButton selected.
     */
    func selectArea(sender: CheckButton) {
        if !sender.selected {
            if let button = self.selectedAreaButton {
                button.selected = false
            }
            sender.selected = true
            self.selectedAreaButton = sender
        }
        else {
            sender.selected = false
            self.selectedAreaButton = nil
        }
    }
    
    /**
     Dismiss current view controller with animation.
     */
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Action when clicking nagivation right button.
     */
    func search() {
        if let button = self.selectedCategoryButton, indexPath = button.indexPath, category = self.categories[safe: indexPath.row] {
            self.searchFilter.category = category
        }
        else {
            self.searchFilter.category = nil
        }
        
        if let button = self.selectedAreaButton, indexPath = button.indexPath, area = self.areas[safe: indexPath.row] {
            self.searchFilter.area = area
        }
        else {
            self.searchFilter.area = nil
        }
        
        if let delegate = self.delegate {
            delegate.startFilterSearch(self)
        }
        
        // Navigate back to home view controller
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Help function
    
    /**
     Load post category list.
     */
    private func loadPostCategories() {
        PostCategory.loadCategories { (categories, error) -> Void in
            guard error == nil else {
                ErrorHandler.log(error)
                return
            }
            
            self.categories = categories
            self.tableView.reloadData()
        }
    }
    
    /**
     Load post area list asynchronously.
     */
    private func loadSearchAreas() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            guard let plistPath = NSBundle.mainBundle().pathForResource("search_areas", ofType: "plist"),
                areaDict = NSDictionary.init(contentsOfFile: plistPath) as? [String: [String: Double]] else { return }
            
            for area in areaDict {
                if let latitude = area.1["Latitude"], longitude = area.1["Longitude"] {
                    self.areas.append(Area(name: area.0, latitude: latitude, longitude: longitude))
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
}

// MARL: CheckButton delegate

extension PostFilterViewController: CheckButtonDelegate {
    func check(checkButton: CheckButton) {
        guard let indexPath = checkButton.indexPath else { return }
        
        switch indexPath.section {
        case 0:
            self.selectCategory(checkButton)
        default:
            self.selectArea(checkButton)
        }
    }
}

// MARK: PostFilterViewController delegate

protocol PostFilterViewControllerDelegate {
    func startFilterSearch(filterVC: PostFilterViewController)
}

