//
//  DataInputTextField.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class DataInputTextField: UIView {
    
    var inputTextField = UITextField()
    private var informationLabel = UILabel()
    private var actionView: UIView?
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
    
    var actionHolder : UIView? {
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
    var delegate: DataInputTextFieldDelegate? {
        didSet {
            inputTextField.delegate = delegate
        }
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setProperty()
    }
    
    func setProperty() {
        // Set up textfield
        inputTextField.font = Constants.General.Font.InputFont
        inputTextField.textColor = Constants.General.Color.InputTextColor
        inputTextField.clearsOnBeginEditing = false
        inputTextField.clearButtonMode = .Never
        inputTextField.autocapitalizationType = .None
        
        // Set up components
        informationLabel.textColor = Constants.General.Color.ErrorColor
        informationLabel.font = Constants.General.Font.ErrorFont
        informationLabel.numberOfLines = 0
        informationLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func drawRect(rect: CGRect) {
        // set information view and its stack view
        let informationStackView = UIStackView()
        informationStackView.axis = .Horizontal
        informationStackView.distribution = .Fill
        informationStackView.alignment = UIStackViewAlignment.Top
        informationStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        informationLabel.sizeToFit()
        informationStackView.addArrangedSubview(informationLabel)
        if let view = actionView {
            view.sizeToFit()
            informationStackView.addArrangedSubview(view)
        }
        if let text = informationLabel.text {
            informationStackView.heightAnchor.constraintEqualToConstant(text.heightWithConstrainedWidth(informationLabel.frame.width, font: Constants.General.Font.ErrorFont!)).active = true
        }
        
        // Set textfield's stack view
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 4
        
        stackView.addArrangedSubview(inputTextField)
        stackView.addArrangedSubview(informationStackView)
        stackView.addArrangedSubview(UIView())
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        
        addSubview(stackView)
        
        //Constraints
        stackView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    func drawUnderlineBorder() {
        if underline.frame.height == 0 {
            inputTextField.borderStyle = .None
            inputTextField.layer.addSublayer(underline)
        }
        
        // Set frame
        underline.frame = CGRectMake(0, inputTextField.frame.height - 1, inputTextField.frame.width, 1.0)
        
        // Set underline color
        if let error = errorText where error.characters.count > 0 {
            underline.backgroundColor = Constants.General.Color.ErrorColor.CGColor
        }
        else {
            underline.backgroundColor = Constants.General.Color.BorderColor.CGColor
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
        self.delegate?.doneToolButtonClicked(sender)
    }
}

@objc protocol DataInputTextFieldDelegate: UITextFieldDelegate {
    func doneToolButtonClicked(sender: UIBarButtonItem);
}