//
//  SystemButton.swift
//  Wumi
//
//  Created by Herman on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class SystemButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Set up the values for this button. It is
        // called here when the button first appears and is also called
        // from the main ViewController when the app is reset.
        
        layer.cornerRadius = 15
        
        backgroundColor = UIColor.orangeColor()
    }
}
