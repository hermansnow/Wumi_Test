//
//  PostTextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostTextView: UITextView {
    
    var characterLimit: Int?
    var selfUserInteractionEnabled: Bool = true // control user interaction of view itself but not subviews
    
    var placeholder: String?
    
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
        self.dataDetectorTypes = .All
    }
    
    func checkRemainingCharacters() -> Int? {
        if let limit = self.characterLimit {
            return limit - self.text.characters.count
        }
        else {
            return nil
        }
    }
    
    // Override hitTest function to only disable user interaction with this view but not subviews
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self && self.selfUserInteractionEnabled == false {
            return nil
        }
        else {
            return hitView
        }
    }
}
