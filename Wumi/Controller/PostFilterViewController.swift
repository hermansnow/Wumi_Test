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
    lazy var areas = [Area]()
    var selectedCategoryButton: UIButton?
    var selectedAreaButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize navigation bar
        self.searchButton = UIBarButtonItem(title: "Search", style: .Done, target: self, action: #selector(searchPost(_:)))
        self.navigationItem.rightBarButtonItem = self.searchButton
        
        // Load categories
        self.loadPostCategories()
        
        // Load search areas
        self.loadSearchAreas()
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCategoryCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            self.categoryCell(cell, forRowAtIndexPath: indexPath)
        case 1:
            self.areaCell(cell, forRowAtIndexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    private func categoryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let category = self.categories[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = category.name
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Check),
                             forState: .Selected)
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Uncheck),
                             forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(selectCategory(_:)), forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    private func areaCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let area = self.areas[safe: indexPath.row] else { return }
        
        cell.textLabel!.text = area.name
        
        let checkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Check),
                             forState: .Selected)
        checkButton.setImage(UIImage(named: Constants.General.ImageName.Uncheck),
                             forState: .Normal)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(selectArea(_:)), forControlEvents: .TouchUpInside)
        cell.accessoryView = checkButton
        
        cell.selectionStyle = .None
    }
    
    // MARK: Action
    
    func selectCategory(sender: UIButton) {
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
    
    func selectArea(sender: UIButton) {
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
    
    func searchPost(sender: AnyObject) {
        // Navigate back to home view controller
        guard let homeVC = self.navigationController?.viewControllers.filter({ $0 is HomeViewController }).first as? HomeViewController else { return }
        
        if let button = self.selectedCategoryButton, category = self.categories[safe: button.tag] {
            homeVC.searchFilter.category = category
            homeVC.needResearch = true
        }
        else {
            homeVC.searchFilter.category = nil
        }
        
        if let button = self.selectedAreaButton, area = self.areas[safe: button.tag] {
            homeVC.searchFilter.area = area
            homeVC.needResearch = true
        }
        else {
            homeVC.searchFilter.area = nil
        }
        
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
    
    private func loadSearchAreas() {
        guard let plistPath = NSBundle.mainBundle().pathForResource("search_areas", ofType: "plist"),
            areaDict = NSDictionary.init(contentsOfFile: plistPath) as? [String: [String: Double]] else { return }
        
        for area in areaDict {
            if let latitude = area.1["Latitude"], longitude = area.1["Longitude"] {
                self.areas.append(Area(name: area.0, latitude: latitude, longitude: longitude))
            }
        }
    }
}
