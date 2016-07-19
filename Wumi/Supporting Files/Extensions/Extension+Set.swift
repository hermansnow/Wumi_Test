//
//  Extension+Set.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension Set {
    // Subscript to get element from set from a specific index
    subscript(index index: Int) -> Element? {
        return self[startIndex.advancedBy(index)]
    }
    
    // Map a set to an array
    func toArray <T: Hashable>(map: (Element) -> T?) -> Set<T> {
        var result = Set<T>()
        
        for element in self {
            if let value = map(element) {
                result.insert(value)
            }
        }
        
        return result
    }
}