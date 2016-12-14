//
//  Location.swift
//  Wumi
//
//  Created by Zhe Cheng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import MapKit

struct Location: CustomStringConvertible {
    var countryCode: String?
    var countryName: String?
    var state: String?
    var city: String?
    
    var description: String {
        return Location.show(CountryName: self.countryName, State: self.state, City: self.city)
    }
    
    var shortDiscription: String {
        return Location.show(CountryName: self.countryCode, State: self.state, City: self.city)
    }
    
    init(CountryCode countryCode: String? = nil, CountryName countryName: String? = nil, State state: String? = nil, City city: String? = nil) {
        self.countryCode = countryCode
        self.countryName = countryName
        // Get display name based on country code if needed
        if let code = self.countryCode where self.countryName == nil {
            self.countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: code)
        }
        self.state = state
        self.city = city
    }
    
    static func show(CountryName countryName: String?, State state: String?, City city: String?) -> String {
        return [city, state, countryName].flatMap{ $0 }.joinWithSeparator(", ")
    }
    
    func calculateCoordinate(completionHandler: CLGeocodeCompletionHandler) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.description, completionHandler: completionHandler)
    }
}

// MARK: Equatable

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.countryCode == rhs.countryCode && lhs.state == rhs.state && lhs.city == rhs.city
}

func !=(lhs: Location, rhs: Location) -> Bool {
    return !(lhs == rhs)
}
