//
//  Area.swift
//  Wumi
//
//  Created by Zhe Cheng on 10/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct Area {
    var name: String
    var latitude: Double
    var longitude: Double
}

// MARK: Equatable

func ==(lhs: Area, rhs: Area) -> Bool {
    return lhs.name == rhs.name
}

