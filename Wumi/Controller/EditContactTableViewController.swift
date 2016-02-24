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
    var contact: Contact!
    var location: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user.contact.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
            if error != nil {
                print("Error when fetch contact for user " + "\(self.user)" + ": " + "\(error)")
                return
            }
            
            if let contact = result as? Contact {
                self.contact = contact
                self.location = Location(Country: contact.country, City: contact.city)
                self.displayContactInformation()
            }
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
            contact.country = selectedLocation.country
            contact.city = selectedLocation.city
            contact.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.location = selectedLocation
                    self.displayContactInformation() // Update cell
                }
                else {
                    self.contact.country = self.location?.country
                    self.contact.city = self.location?.city
                    Helper.PopupErrorAlert(self, errorMessage: "\(error)")
                }
            })
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Country List" {
            if let countryListViewController = segue.destinationViewController as? LocationListTableViewController {
                countryListViewController.locationDelegate = self
                countryListViewController.selectedLocation = Location(Country: contact.country, City: contact.city)
            }
        }
    }
    

}
