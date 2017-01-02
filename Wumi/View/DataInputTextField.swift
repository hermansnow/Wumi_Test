//
//  DataInputTextField.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class DataInputTextField: UIView {
    
    /// Input text field of data input text field view.
    var inputTextField = UITextField()
    /// View holder for action components, currently is used for error handler components.
    var actionView: UIView? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// Label to show information, such as error message.
    private var informationLabel = UILabel()
    /// Underline of input view.
    private var underlineLayer = CALayer()
    /// Stack view includes informationLabel and action view.
    private var informationStackView = UIStackView()
    
    // MARK: Computed properties
    
    /// Text string of input textfield.
    @IBInspectable var text: String? {
        get {
            return self.inputTextField.text
        }
        set (newValue) {
            self.inputTextField.text = newValue
        }
    }
    
    /// Ghost text string for the placeholder of input textfield.
    @IBInspectable var placeholder: String? {
        get {
            return self.inputTextField.placeholder
        }
        set (newValue) {
            self.inputTextField.placeholder = newValue
        }
    }
    
    /// Error message to be displayed on information label below underline.
    @IBInspectable var errorText: String? {
        get {
            return self.informationLabel.text
        }
        set (newText) {
            self.informationLabel.text = newText
            self.drawUnderlineBorder()
        }
    }
    
    /// Delegate of this DataInputTextField will also be assigned as the delegate of child input textfield.
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
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
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
        self.layer.addSublayer(self.underlineLayer)
        
        // Auto-layout between information label and action view via stackview
        self.informationStackView.axis = .Horizontal
        self.informationStackView.distribution = .Fill
        self.informationStackView.alignment = UIStackViewAlignment.Top
        self.informationStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        // Auto-layout for all subviews via stackview
        let stackView = UIStackView(arrangedSubviews: [self.inputTextField, self.informationStackView, UIView()])
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(stackView)
        
        // Add auto-layout constraints
        stackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Add subviews (information label or action view) for information stack
        self.informationLabel.sizeToFit()
        informationStackView.addArrangedSubview(self.informationLabel)
        if self.actionView != nil {
            self.actionView!.sizeToFit()
            informationStackView.addArrangedSubview(self.actionView!)
        }
        
        // Calculate information label height based on width and font
        if let text = self.informationLabel.text {
            self.informationStackView.heightAnchor.constraintEqualToConstant(text.heightWithConstrainedWidth(self.informationLabel.frame.width,
                                                                                                             font: Constants.General.Font.ErrorFont)).active = true
        }
    }
    
    /**
     Draw underline border layer for input textfield. This function is also used to update underline style.
     */
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
    
    /**
     Add a tool bar as input textfield's input accessory view with a done button.
     */
    func addDoneButtonToInputTextField() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneToolButtonClicked(_:)))
        
        toolbar.barStyle = .Default
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputTextField.inputAccessoryView = toolbar
    }
    
    /**
     Clean error message and handler.
     */
    func cleanError() {
        if self.errorText != nil {
            self.errorText = nil
            self.actionView = nil
        }
    }
    
    // MARK: Actions
    
    /**
     Action when done button is clicked.
     
     - Parameters:
        - sender: The clicked UIBarButtonItem.
     */
    func doneToolButtonClicked(sender: UIBarButtonItem) {
        guard let delegate = self.delegate, clickAction = delegate.clickDoneButton else { return }
        
        clickAction(sender)
    }
}

// MARK: DataInputTextFieldDelegate

@objc protocol DataInputTextFieldDelegate: UITextFieldDelegate {
    /**
     Action handler for clicking done button on input textfield's custom keyboard accessary tool bar.
     
     - Parameters:
        - sender: The clicked UIBarButtonItem.
     */
    optional func clickDoneButton(sender: UIBarButtonItem)
}
