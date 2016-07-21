//
//  Extension+Array.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension Array {
    // Subscript to get element from index safely without overflow crash
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    // Group array elements based on a sepcific key
    func groupBy<Key: Hashable>(group: (Element) -> Key) -> [Key: [Element]] {
        var result = [Key: [Element]]()
        
        for element in self {
            let groupKey = group(element)
            
            if result[groupKey] == nil {
                result[groupKey] = [Element]()
            }
            result[groupKey]?.append(element)
        }
        
        return result
    }
    
    mutating func appendUniqueObject<T: Equatable>(object: T) {
        for index in indices.sort(>) {
            if let element = self[index] as? T where element == object { return }
        }
        self.append(object as! Element)
    }
    
    // Remove list of items
    mutating func removeAtIndexes(indexes:[Int]) -> () {
        for index in indexes.sort(>) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObject<T: Equatable>(object: T) {
        for index in indices.sort(>) {
            guard let element = self[index] as? T where element == object else { continue }
            self.removeAtIndex(index)
        }
    }
}