//
//  Extension+MKMapView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

extension MKMapView {
    /**
     Update map center based on a pass-in location point with a specific radius.
     
     - Parameters:
        - location: location point will be assigned as map center.
        - WithRadius: Radius of visible map area.
     */
    func centerMapOnLocation(location: CLLocation, WithRadius radius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radius * 2.0,
                                                                  radius * 2.0)
        self.setRegion(coordinateRegion, animated: true)
        
        // Cache new center location.
        MKMapView.cacheMapCenter(location)
    }
    
    /**
     Cache a map center location point's geo data (latitude and longitude).
     
     - Parameters:
        - location: location point as a map center.
     */
    class func cacheMapCenter(location: CLLocation) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        userDefault.setDouble(location.coordinate.latitude, forKey: "center_latitide")
        userDefault.setDouble(location.coordinate.longitude, forKey: "center_longitude")
        
        userDefault.synchronize()
    }
    
    /**
     Fetch a map center location point with its geo data (latitude and longitude) from cache.
     
     - Return:
        A CLLocation object as cached map center.
     */
    class func getMapCenterCache() -> CLLocation? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        guard let latitude = userDefault.objectForKey("center_latitide") as? Double,
            longitude = userDefault.objectForKey("center_longitude") as? Double else { return nil }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
