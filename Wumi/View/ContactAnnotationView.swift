//
//  ContactAnnotationView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

class ContactAnnotationView: MKAnnotationView {
    
    var avatarImageView = AvatarImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var detail: String? {
        get {
            return self.detailLabel.text
        }
        set {
            self.detailLabel.text = newValue
        }
    }
    private var detailLabel = UILabel()
    
    // MARK: Initializers
    override init(annotation: MKAnnotation?, reuseIdentifier identifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: identifier)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    private func setProperty() {
        self.canShowCallout = true
        self.image = UIImage(named: "Contact_Pin")
        
        // Set up accessory views
        self.detailLabel.textColor = Constants.Post.Color.ListDetailText
        self.detailLabel.font = Constants.Post.Font.ListUserBanner
        self.detailCalloutAccessoryView = self.detailLabel
        
        self.leftCalloutAccessoryView = self.avatarImageView
        let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        forwardButton.setImage(UIImage(named: "Forward"), forState: .Normal)
        self.rightCalloutAccessoryView = forwardButton
        
    }

}
