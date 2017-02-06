//
//  ContactAnnotationView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

class ContactAnnotationView: MKAnnotationView {
    /// Avatar image view to be shown on annotation's left callout accessory view.
    private var avatarImageView = AvatarImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    /// Label for details of annotation.
    private var detailLabel = UILabel()
    /// Avatar image of annotation on left callout accessory view.
    var avatarImage: UIImage? {
        get {
            return self.avatarImageView.image
        }
        set {
            self.avatarImageView.image = newValue
        }
    }
    /// Detail text of annotation's detail callout accessory view.
    var detail: String? {
        get {
            return self.detailLabel.text
        }
        set {
            self.detailLabel.text = newValue
        }
    }
    
    // MARK: Initializers
    
    override init(annotation: MKAnnotation?, reuseIdentifier identifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: identifier)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.canShowCallout = true
        self.image = UIImage(named: "Contact_Pin")
        
        // Set up detail label
        self.detailLabel.textColor = Constants.Post.Color.ListDetailText
        self.detailLabel.font = Constants.Post.Font.ListUserBanner
        
        // Set up accessory views
        self.detailCalloutAccessoryView = self.detailLabel
        self.leftCalloutAccessoryView = self.avatarImageView
        let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        forwardButton.setImage(UIImage(named: "Forward"), forState: .Normal)
        self.rightCalloutAccessoryView = forwardButton
        
    }

}
