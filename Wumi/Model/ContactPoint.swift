//
//  ContactPoint.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

class ContactPoint: NSObject, MKAnnotation {
    /// Title of annotation.
    var title: String?
    /// Detailed description of annotation.
    var detail: String?
    /// Location coordinate data for annoation.
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    /// User contact this annoation represents.
    var contact: User? {
        didSet {
            if let contact = self.contact {
                self.title = contact.nameDescription
                self.detail = contact.location.shortDiscription
            }
        }
    }
    
    // MARK: Initializers
    
    convenience init(Contact contact: User) {
        self.init()
        // Use tricky way to invoke didSet for user property
        defer {
            self.contact = contact
        }
    }
}
