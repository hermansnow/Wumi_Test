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
        return [country, city].flatMap{$0}.joinWithSeparator(", ")
    }
    
    init(Country country: String?, City city: String?) {
        self.country = country
        self.city = city
    }
}
