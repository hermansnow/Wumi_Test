//
//  PIKAQuadData.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

struct PIKAQuadData {
    /// X coordinate of data node.
    var x: Double
    /// Y coordinate of data node.
    var y: Double
    /// Any custom type of data.
    var data: AnyObject?
    
    // MARK: Initializers
    
    init(x: Double, y: Double, data: AnyObject? = nil) {
        self.x = x
        self.y = y
        self.data = data
    }
}
