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
    var city: String?
    
    var description: String {
        return Location.show(Country: self.country, City: self.city)
    }
    
    init(Country country: String?, City city: String?) {
        self.country = country
        self.city = city
    }
    
    static func show(Country country: String?, City city: String?) -> String {
        return [country, city].flatMap{ $0 }.joinWithSeparator(", ")
    }
}
