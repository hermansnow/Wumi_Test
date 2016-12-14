//
//  ContactPoint.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit

class ContactPoint: NSObject, MKAnnotation {
    
    var title: String?
    var detail: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var user: User? {
        didSet {
            if let user = self.user {
                self.title = user.nameDescription
                self.detail = user.location.shortDiscription
            }
        }
    }
    
    convenience init(User user: User) {
        self.init()
        // Use tricky way to invoke didSet for user property
        defer {
            self.user = user
        }
    }
}
