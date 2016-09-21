//
//  ColorGradientView.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ColorGradientView: UIView {
    
    private var gradientColors = [UIColor]()
    
    var colors: [UIColor] {
        get {
            return self.gradientColors
        }
        set (newColors) {
            self.gradientColors = newColors
        }
    }
    
    // MARK: Draw view
    
    override func drawRect(rect: CGRect) {
        let colorPercent = 1.0 / Double(self.gradientColors.count)
        
        // Set gradient
        for i in 0..<self.gradientColors.count {
            self.gradientColors[i].setFill()
            let yOffset = CGFloat(Double(i) * colorPercent)
            let rect = CGRect(x: rect.origin.x,
                              y: rect.origin.y + (yOffset * rect.size.height),
                          width: rect.size.width,
                         height: rect.size.height * CGFloat(colorPercent))
            CGContextFillRect(UIGraphicsGetCurrentContext()!, rect);
        }
        
        self.backgroundColor?.setFill()
    }
}
