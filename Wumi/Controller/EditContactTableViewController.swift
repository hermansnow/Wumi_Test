//
//  EditContactTableViewController.swift
//  Wumi
//
//  Created by Herman on 2/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class EditContactTableViewController: UITableViewController, LocationListDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    
    var user = User.currentUser()
    var location: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create contact if it is nil
        if user.contact ==  nil {
            user.contact = Contact()
            user.saveInBackground()
            displayContactInformation()
        }
        // Otherwise, fetch data from server
        else {
            user.contact!.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                if error != nil {
                    print("Error when fetch contact for user " + "\(self.user)" + ": " + "\(error)")
                    return
                }
                
                if let contact = result as? Contact {
                    self.location = Location(Country: contact.country, City: contact.city)
                    self.displayContactInformation()
                }
            }
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Save contact changes
            user.contact?.saveInBackground()
        }
    }
    
    private func displayContactInformation() {
        locationLabel.text = (location == nil || "\(location!)".isEmpty) ? "Please select your location" : "\(location!)"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    // MARK: Tableview delegates
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("Show Country List", sender: self)
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: Save selected data
    func finishLocationSelection(location: Location?) {
        if let selectedLocation = location {
            user.contact!.country = selectedLocation.country
            user.contact!.city = selectedLocation.city
            self.location = selectedLocation
            self.displayContactInformation() // Update cell
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Country List" {
            if let countryListViewController = segue.destinationViewController as? LocationListTableViewController {
                countryListViewController.locationDelegate = self
                countryListViewController.selectedLocation = Location(Country: user.contact!.country, City: user.contact!.city)
            }
        }
    }
    

}
