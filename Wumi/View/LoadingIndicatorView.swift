//
//  LoadingIndicatorView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import DGActivityIndicatorView

class LoadingIndicatorView: DGActivityIndicatorView {
    
    
    // MARK: Initializers
    
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
    
    private func setProperty() {
        //self.type = .LineSpinFadeLoader
       // self.padding = 1.0
       // self.color = Constants.General.Color.ThemeColor
        //self.hidesWhenStopped = true
    }

}
