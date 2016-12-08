//
//  ButtomBorderView.swift
//  Wumi
//
//  Created by Zhe Cheng on 12/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ButtomBorderView: UIView {
    
    var borderColor: UIColor = Constants.General.Color.LightBorderColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func drawRect(rect: CGRect) {
        // Drawing code
        let buttomLayer = CALayer()
        buttomLayer.backgroundColor = self.borderColor.CGColor
        buttomLayer.frame = CGRect(x: 0, y: rect.height - 1, width: rect.width, height: 1)
        self.layer.addSublayer(buttomLayer)
    }

}
