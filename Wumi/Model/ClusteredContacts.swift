//
//  ClusteredContacts.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import MapKit

class ClusteredContacts: NSObject, MKAnnotation {
    /// Location coordinate data for annoation.
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    /// Array of clustered contact points.
    var contactPoints = [ContactPoint]() {
        didSet {
            guard self.contactPoints.count > 0 else { return }
            
            // Calculate average latitude and longitude as the annotation's coordinate
            var totalLatitude: Double = 0
            var totalLongitude: Double = 0
            for contactPoint in contactPoints {
                totalLatitude += contactPoint.coordinate.latitude
                totalLongitude += contactPoint.coordinate.longitude
            }
            self.coordinate.latitude = CLLocationDegrees(totalLatitude)/CLLocationDegrees(self.contactPoints.count)
            self.coordinate.longitude = CLLocationDegrees(totalLongitude)/CLLocationDegrees(self.contactPoints.count)
        }
    }
    
    // MARK: Initializers
    
    convenience init(contactPoints: [ContactPoint]) {
        self.init()
        
        // Use tricky way to invoke didSet for contactPoints property
        defer {
            self.contactPoints = contactPoints
        }
    }
}
