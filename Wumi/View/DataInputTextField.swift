//
//  DataInputTextField.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class DataInputTextField: UIView {
    
    private var dataInputDelegate: DataInputTextFieldDelegate?
    
    var inputTextField = UITextField()
    var informationHolder = UIView()
    
    @IBInspectable var text: String? {
        get {
            return inputTextField.text
        }
        set (newValue) {
            inputTextField.text = newValue
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return inputTextField.placeholder
        }
        set (newValue) {
            inputTextField.placeholder = newValue
        }
    }
        
    /*override var delegate: UITextFieldDelegate? {
        didSet {
            dataInputDelegate = delegate as? DataInputTextFieldDelegate
        }
    }*/
    
    override func drawRect(rect: CGRect) {
        // Set up textfield
        inputTextField.font = UIFont(name: ".SFUIText-Light", size: 16)
        inputTextField.clearsOnBeginEditing = false
        inputTextField.clearButtonMode = .WhileEditing
        
        // Add underline
        drawUnderlineBorder()
        
        //Stack View
        let stackView = UIStackView()
        stackView.axis = .Vertical;
        stackView.distribution = .Fill;
        stackView.alignment = .Fill;
        stackView.spacing = 10;
        
        stackView.addArrangedSubview(inputTextField)
        stackView.addArrangedSubview(informationHolder)
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        
        addSubview(stackView)
        
        //Constraints
        stackView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        
        super.drawRect(rect)
    }
    
    func drawUnderlineBorder() {
        let underline = CALayer()
        underline.frame = CGRectMake(0, inputTextField.frame.height - 1, inputTextField.frame.width, 1.0)
        underline.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0).CGColor
        inputTextField.borderStyle = .None
        inputTextField.layer.addSublayer(underline)
    }
    
    // MARK:View components functions
    func addInputToolBar() {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        toolbar.barStyle = .Default;
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneToolButtonClicked:"))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        inputTextField.inputAccessoryView = toolbar
    }
    
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        self.dataInputDelegate?.doneToolButtonClicked(sender)
    }
}

@objc protocol DataInputTextFieldDelegate: UITextFieldDelegate {
    func doneToolButtonClicked(sender: UIBarButtonItem);
}