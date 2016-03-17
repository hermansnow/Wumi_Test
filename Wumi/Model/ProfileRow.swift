//
//  ProfileRow.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

struct ProfileRow {
    var title: String?
    
    init(title: String?) {
        self.title = title
    }
}

// MARK: String Literal protocol

extension ProfileRow: StringLiteralConvertible {
    init(stringLiteral value: StringLiteralType) {
        self = ProfileRow.rowFromString(value)
    }
    
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = ProfileRow.rowFromString(value)
    }
    
    init(unicodeScalarLiteral value: StringLiteralType) {
        self = ProfileRow.rowFromString(value)
    }
    
    static func rowFromString(value: String) -> ProfileRow {
        let valueArr =  value.characters.split(",").map{ String($0) }
        let title = valueArr[safe: 0]
        
        return ProfileRow(title: title)
    }
}

// MARK: Equatable protocol

extension ProfileRow: Equatable { }

func ==(lhs: ProfileRow, rhs: ProfileRow) -> Bool {
    return lhs.title == rhs.title
}