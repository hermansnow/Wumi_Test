//
//  PostTextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class PostTextView: KMPlaceholderTextView {
    
    static var characterLimit = 300
    
    func checkRemainingCharacters() -> Int {
        return PostTextView.characterLimit - self.text.characters.count
    }
}
