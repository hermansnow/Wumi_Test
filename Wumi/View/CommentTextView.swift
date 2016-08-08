//
//  CommentTextView.swift
//  Wumi
//
//  Created by JunpengLuo on 4/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CommentTextView: UITextView {

    // MARK: Properties
    
    weak var parentCell: CommentTableViewCell!
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Help functions
    
    func setProperty() {
        self.scrollEnabled = false
        self.selectable = true
        self.editable = false
        self.dataDetectorTypes = .All
        self.userInteractionEnabled = true
        self.textContainer.maximumNumberOfLines = 0
        
        // Remove default margin/padding.
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsetsZero
        self.textAlignment = .Left
    }
}
