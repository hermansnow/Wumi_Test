//
//  Extension+MKMapView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import MapKit

extension MKMapView {
    func centerMapOnLocation(location: CLLocation, WithRadius radius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radius * 2.0,
                                                                  radius * 2.0)
        self.setRegion(coordinateRegion, animated: true)
        
        MKMapView.cacheMapCenter(location)
    }
    
    class func cacheMapCenter(location: CLLocation) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        userDefault.setDouble(location.coordinate.latitude, forKey: "center_latitide")
        userDefault.setDouble(location.coordinate.longitude, forKey: "center_longitude")
        
        userDefault.synchronize()
    }
    
    class func getMapCenterCache() -> CLLocation? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        guard let latitude = userDefault.objectForKey("center_latitide") as? Double,
            longitude = userDefault.objectForKey("center_longitude") as? Double else { return nil }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
