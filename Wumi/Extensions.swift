//
//  Extensions.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}