//
//  ContactViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoriteButton: DOFavoriteButton!
    @IBOutlet weak var maskView: UIView!
    
    var user: User?
    var loginUser = User.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contactUser = user {
            contactUser.loadAvatar(CGSize(width: backgroundImageView.frame.width, height: backgroundImageView.frame.height)) { (image, error) -> Void in
                if error != nil {
                    print("\(error)")
                }
                
                self.backgroundImageView.image = image
            }
            
            maskView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            
            nameLabel.text = contactUser.name
            
            if contactUser.graduationYear > 0 {
                graduationYearLabel.text = "(\(contactUser.graduationYear))"
            }
            else {
                graduationYearLabel.text = ""
            }
            
            locationLabel.text = ""
            if let contact = user?.contact {
                locationLabel.text = "\(Location(Country: contact.country, City: contact.city))"
            }
            
            favoriteButton.imageColorOff = UIColor.brownColor()
            favoriteButton.imageColorOn = Constants.UI.Color.ThemeColor
            favoriteButton.circleColor = Constants.UI.Color.ThemeColor
            favoriteButton.lineColor = Constants.UI.Color.ThemeColor
            favoriteButton.duration = 1.0 // default: 1.0
            loginUser.isFavoriteUser(user) { (count, error) -> Void in
                if error != nil {
                    print("\(error)")
                    return
                }
                
                self.favoriteButton.selected = (count > 0)
            }
        }
    }
}
