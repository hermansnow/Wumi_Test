//
//  EmptyPostView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class EmptyPostView: UIView {
        
    private lazy var noDataLabel = UILabel()
    
    var text: String? {
        didSet {
            self.noDataLabel.text = self.text
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = self.backgroundColor
            self.noDataLabel.backgroundColor = self.backgroundColor
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            
        self.setProperty()
    }
        
    private func setProperty() {
        self.noDataLabel.textColor = Constants.General.Color.BackgroundColor
        self.noDataLabel.font = Constants.Post.Font.ListTitle
        self.noDataLabel.textAlignment = .Center
        self.noDataLabel.numberOfLines = 0
        self.addSubview(self.noDataLabel)
    }
        
    override func layoutSubviews() {
        self.noDataLabel.frame = self.bounds
    }
}
