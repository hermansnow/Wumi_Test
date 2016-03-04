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
    private var informationLabel = UILabel()
    private var actionView = UIView()
    private var underline = CALayer()
    
    // Computed properties
    var informationHolder: UILabel {
        get {
            return informationLabel
        }
        set (newLabel) {
            informationLabel = newLabel
            setNeedsDisplay()
        }
    }
    
    var actionHolder : UIView {
        get {
            return actionView
        }
        set (newView) {
            actionView = newView
            setNeedsDisplay()
        }
    }
    
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
    
    @IBInspectable var errorText: String? {
        get {
            return informationLabel.text
        }
        set (newText) {
            informationLabel.text = newText
            drawUnderlineBorder()
        }
    }
    
    // Delegate
    var delegate: UITextFieldDelegate? {
        didSet {
            dataInputDelegate = delegate as? DataInputTextFieldDelegate
            inputTextField.delegate = delegate
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        // Set up textfield
        inputTextField.font = UIFont(name: ".SFUIText-Light", size: 16)
        inputTextField.textColor = UIColor(red: 51/255, green: 52/255, blue: 53/255, alpha: 1.0)
        inputTextField.clearsOnBeginEditing = false
        inputTextField.clearButtonMode = .WhileEditing
        inputTextField.autocapitalizationType = .None
        
        // Set up components
        informationLabel.textColor = Constants.UI.Color.ErrorColor
        informationLabel.font = Constants.UI.Font.ErrorFont
        informationLabel.numberOfLines = 0
        informationLabel.adjustsFontSizeToFitWidth = true
        
        informationLabel.sizeToFit()
        actionView.sizeToFit()
        
        // set information view
        let informationStackView = UIStackView()
        informationStackView.axis = .Horizontal;
        informationStackView.distribution = .FillProportionally;
        informationStackView.alignment = .LastBaseline;
        
        informationStackView.addArrangedSubview(informationLabel)
        informationStackView.addArrangedSubview(actionView)
        informationStackView.translatesAutoresizingMaskIntoConstraints = false;

        
        // Set stack View
        let stackView = UIStackView()
        stackView.axis = .Vertical;
        stackView.distribution = .FillEqually;
        stackView.alignment = .Fill;
        stackView.spacing = 4;
        
        stackView.addArrangedSubview(inputTextField)
        stackView.addArrangedSubview(informationStackView)
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
        if underline.frame.height == 0 {
            inputTextField.borderStyle = .None
            underline.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0).CGColor
            inputTextField.layer.addSublayer(underline)
        }
        
        // Set frame
        underline.frame = CGRectMake(0, inputTextField.frame.height - 1, inputTextField.frame.width, 1.0)
        
        // Set underline color
        if let error = errorText where error.characters.count > 0 {
            underline.backgroundColor = Constants.UI.Color.ErrorColor.CGColor
        }
        else {
            underline.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0).CGColor
        }
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