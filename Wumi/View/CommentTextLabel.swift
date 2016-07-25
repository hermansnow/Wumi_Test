//
//  CommentTextLabel.swift
//  Wumi
//
//  Created by JunpengLuo on 4/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CommentTextLabel: UILabel {

    weak var parentCell: CommentTableViewCell!
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.textColor = Constants.General.Color.TextColor
        self.font = Constants.Post.Font.ListTitle
    }
}
