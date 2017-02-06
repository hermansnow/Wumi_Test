//
//  PIKAQuadBoundingBox.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

struct PIKAQuadBoundingBox {
    var x, x1, y, y1: Double
    
    var xMid: Double {
        return (self.x + self.x1) / 2
    }
    var yMid: Double {
        return (self.y + self.y1) / 2
    }
    
    init(x: Double, y: Double, x1: Double, y1: Double) {
        self.x = x
        self.x1 = x1
        self.y = y
        self.y1 = y1
    }
    
    func contains(data: PIKAQuadData) -> Bool {
        return self.x <= data.x && data.x <= self.x1 && self.y <= data.y && data.y <= self.y1
    }
    
    func intersects(box: PIKAQuadBoundingBox) -> Bool {
        return self.x <= box.x1 && self.x1 >= box.x && self.y <= box.y1 && self.y1 >= box.y
    }
}
