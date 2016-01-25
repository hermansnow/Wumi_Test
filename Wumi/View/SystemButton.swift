//
//  SystemButton.swift
//  Wumi
//
//  Created by Herman on 11/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class SystemButton: UIButton {

    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = 20; //half of the width
        
        super.drawRect(rect)
    }
}
