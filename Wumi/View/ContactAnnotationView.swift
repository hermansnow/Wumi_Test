//
//  ContactAnnotationView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

class ContactAnnotationView: MKAnnotationView {
    /// ContactAnnotationView delegate.
    var delegate: ContactAnnotationViewDelegate?
    /// Avatar image view to be shown on annotation's left callout accessory view.
    private var avatarImageView = AvatarImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    /// Avatar image of annotation on left callout accessory view.
    var avatarImage: UIImage? {
        get {
            return self.avatarImageView.image
        }
        set {
            self.avatarImageView.image = newValue
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
        
        // Add gesture recognizer
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap)))
        
        // Set up accessory views
        self.leftCalloutAccessoryView = self.avatarImageView
        let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        forwardButton.setImage(UIImage(named: "Forward"), forState: .Normal)
        self.rightCalloutAccessoryView = forwardButton
    }
    
    /**
     Function triggered when tapped.
     */
    func tap() {
        guard let delegate = self.delegate, tapCallout = delegate.tapCallout where self.selected else { return }
        
        tapCallout(self)
    }
}

// MARK: ContactAnnotationViewDelegate

@objc protocol ContactAnnotationViewDelegate {
    /**
     Action handler for tapping on callout view.
     
     - Parameters:
        - view: ContactAnnotation view tapped.
     */
    optional func tapCallout(view: ContactAnnotationView)
}
