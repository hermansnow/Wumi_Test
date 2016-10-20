//
//  Location.swift
//  Wumi
//
//  Created by Zhe Cheng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct Location: CustomStringConvertible {
    var country: String?
    var state: String?
    var city: String?
    
    var description: String {
        return Location.show(Country: self.country, State: self.state, City: self.city)
    }
    
    init(Country country: String?, State state: String?, City city: String?) {
        self.country = country
        self.state = state
        self.city = city
    }
    
    static func show(Country country: String?, State state: String?, City city: String?) -> String {
        return [city, state, country].flatMap{ $0 }.joinWithSeparator(", ")
    }
}

// MARK: Equatable

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.country == rhs.country && lhs.state == rhs.state && lhs.city == rhs.city
}

func !=(lhs: Location, rhs: Location) -> Bool {
    return !(lhs == rhs)
}
