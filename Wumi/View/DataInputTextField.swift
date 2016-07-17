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
    private var underlineLayer = CALayer()
    
    // Computed properties
    var informationHolder: UILabel {
        get {
            return self.informationLabel
        }
        set (newLabel) {
            self.informationLabel = newLabel
            self.setNeedsDisplay()
        }
    }
    
    var actionHolder : UIView? {
        get {
            return self.actionView
        }
        set (newView) {
            self.actionView = newView
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var text: String? {
        get {
            return self.inputTextField.text
        }
        set (newValue) {
            self.inputTextField.text = newValue
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return self.inputTextField.placeholder
        }
        set (newValue) {
            self.inputTextField.placeholder = newValue
        }
    }
    
    @IBInspectable var errorText: String? {
        get {
            return self.informationLabel.text
        }
        set (newText) {
            self.informationLabel.text = newText
            self.drawUnderlineBorder()
        }
    }
    
    // Delegate
    var delegate: DataInputTextFieldDelegate? {
        didSet {
            self.inputTextField.delegate = delegate
        }
    }
    
    // MARK: Initializers
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        // Set up textfield
        self.inputTextField.font = Constants.General.Font.InputFont
        self.inputTextField.textColor = Constants.General.Color.TextColor
        self.inputTextField.clearsOnBeginEditing = false
        self.inputTextField.clearButtonMode = .Never
        self.inputTextField.autocapitalizationType = .None
        self.inputTextField.borderStyle = .None
        
        // Set up information view
        self.informationLabel.textColor = Constants.General.Color.ErrorColor
        self.informationLabel.font = Constants.General.Font.ErrorFont
        self.informationLabel.numberOfLines = 0
        self.informationLabel.adjustsFontSizeToFitWidth = true
        
        // Add underline layer
        self.layer.addSublayer(underlineLayer)
    }
    
    // MARK: Draw view
    
    override func drawRect(rect: CGRect) {
        // Auto-layout between information label and action view
        let informationStackView = UIStackView()
        informationStackView.axis = .Horizontal
        informationStackView.distribution = .Fill
        informationStackView.alignment = UIStackViewAlignment.Top
        informationStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        self.informationLabel.sizeToFit()
        informationStackView.addArrangedSubview(informationLabel)
        if self.actionView != nil {
            self.actionView!.sizeToFit()
            informationStackView.addArrangedSubview(self.actionView!)
        }
        
        // Auto-layout for all subviews
        let stackView = UIStackView(arrangedSubviews: [self.inputTextField, informationStackView, UIView()])
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        
        addSubview(stackView)
        
        // Add constraints
        stackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        
        if let text = informationLabel.text {
            informationStackView.heightAnchor.constraintEqualToConstant(text.heightWithConstrainedWidth(informationLabel.frame.width,
                                                                  font: Constants.General.Font.ErrorFont!)).active = true // Calculate information label height based on width and font
        }
    }
    
    // Draw underline border layer for input textfield
    func drawUnderlineBorder() {
        // Set frame
        self.underlineLayer.frame = CGRectMake(0, self.inputTextField.frame.height - 1, self.inputTextField.frame.width, 1.0)
        
        // Set underline color
        if let error = self.errorText where error.characters.count > 0 {
            self.underlineLayer.backgroundColor = Constants.General.Color.ErrorColor.CGColor
        }
        else {
            self.underlineLayer.backgroundColor = Constants.General.Color.BorderColor.CGColor
        }
    }
    
    // MARK: Help functions
    
    func addDoneButtonToInputTextField() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneToolButtonClicked(_:)))
        
        toolbar.barStyle = .Default
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputTextField.inputAccessoryView = toolbar
    }
    
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        guard let delegate = self.delegate, clickAction = delegate.clickDoneButton else { return }
        
        clickAction(sender)
    }
}

@objc protocol DataInputTextFieldDelegate: UITextFieldDelegate {
    optional func clickDoneButton(sender: UIBarButtonItem)
}