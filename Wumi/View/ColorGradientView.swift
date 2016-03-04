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
            return gradientColors
        }
        set (newColors) {
            gradientColors = newColors
            print("aaa" + "\(gradientColors)")
            //setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let colorPercent = 1.0 / Double(gradientColors.count)
        // Set gradient
        for i in 0..<gradientColors.count {
            gradientColors[i].setFill()
            let yOffset = CGFloat(Double(i) * colorPercent)
            let height = rect.size.height * CGFloat(colorPercent)
            let rect = CGRect(x: rect.origin.x, y: rect.origin.y + (yOffset * rect.size.height), width: rect.size.width, height: height)
            CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        }
        
        backgroundColor?.setFill()
        
        
    }

}
