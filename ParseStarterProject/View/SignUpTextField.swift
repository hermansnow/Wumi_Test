//
//  SignUpTextField.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import QuartzCore

class SignUpTextField: UITextField {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.layer.cornerRadius = 10
    }
    
    // Right view of text field is used to show error image if the input is invalid
    func setRightErrorViewForTextFieldWithErrorMessage(error: String = "") {
        if (error.characters.count > 0) {
            let rightErrorView = UIImageView(image: UIImage(named: "Error"))
            
            // Set frame of the right image view
            let viewSize = CGSize(width: self.bounds.height * 0.66, height: self.bounds.height * 0.66)
            let viewOrigin = CGPoint(x: 0, y: (self.bounds.height - viewSize.height) / 2)
            rightErrorView.frame = CGRect(origin: viewOrigin, size: viewSize)
            
            self.rightView = rightErrorView
            self.rightViewMode = .Always
            
            //Log error
            print("\(error)")
        }
        else {
            self.rightView = nil // Remove error image if there is no more error message
        }
    }
    
    // Left view of text field is used to place the icon
    func setLeftImageViewForTextField(image: UIImage?) {
        if let leftImage = image {
            let leftImageView = UIImageView(image: leftImage)
            leftImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
            self.leftView = leftImageView
            self.leftViewMode = .Always
        }
    }

}
