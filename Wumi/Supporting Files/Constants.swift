//
//  Constants.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//
import UIKit
import Foundation

struct Constants {
    
    struct UI {
        
        struct Color {
            static let BackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
            static let MaskColor = UIColor(white: 1.0, alpha: 0.2)
            static let ThemeColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
            static let ErrorColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
        }
        
        struct Font {
            static let ErrorFont = UIFont(name: ".SFUIText-Light", size: 12)
        }
        
        struct Image {
            static let AddAvatarImage = UIImage(named: "Add")
            static let AnonymousAvatarImage = UIImage(named: "Anonymous")
        }
        
        struct Proportion {
            static let MaskHeightWithParentView: CGFloat = 144 / 220
            static let MaskWidthWithHeight: CGFloat = 1.0
        }
    }
    
} 