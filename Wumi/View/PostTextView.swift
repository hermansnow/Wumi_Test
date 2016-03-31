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
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    private func setProperty() {
        self.font = Constants.General.Font.InputFont
    }
    
    func checkRemainingCharacters() -> Int {
        return PostTextView.characterLimit - self.text.characters.count
    }
    
    
}
