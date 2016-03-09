//
//  GraduationYearPickerView.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GraduationYearPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    
    // Subviews: A toolbar with two buttons and an UIPickerView
    var graduationYearPicker: UIPickerView = UIPickerView()
    var toolBar: UIToolbar = UIToolbar()
    
    // Properties to save the year information
    private lazy var currentYear = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
    private lazy var years = [Int]()
    var year: Int = 0 {
        didSet {
            graduationYearPicker.selectRow(self.years.indexOf(self.year)!, inComponent: 0, animated: true)
        }
    }
    
    // Closures passed in from caller. These closures are used by callers to define view behaviors
    var onYearSelected: ((year: Int) -> Void)?
    var comfirmSelection: (() -> Void)?
    var cancelSelection: (() -> Void)?
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupYearList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupYearList()
    }
    
    override func drawRect(rect: CGRect) {
        // Set up top toolbar
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel:")
        let confirmButton: UIBarButtonItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "confirm:")
        let flexibleSpaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolBar.items = [cancelButton, flexibleSpaceBarItem, confirmButton]
        
        // Set up UIPickerView
        graduationYearPicker.backgroundColor = UIColor.whiteColor()
        
        // Add toolbar and UIPickerView into a stackView
        let stackView = UIStackView(arrangedSubviews: [toolBar, graduationYearPicker])
        stackView.alignment = .Fill
        stackView.axis = .Vertical
        stackView.distribution = .EqualSpacing
        stackView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        addSubview(stackView)
        
        super.drawRect(rect)
    }
    
    // MARK: Actions
    
    // Click Cancel bar button
    func cancel(sender: AnyObject) {
        if let block = cancelSelection {
            block()
        }
        self.removeFromSuperview()
    }
    
    // Click Confirm bar button
    func confirm(sender: AnyObject) {
        if let block = comfirmSelection {
            block()
        }
        self.removeFromSuperview()
    }
    
    // MARK: UIPickerView functions
    
    // Set up picker year list
    private func setupYearList() {
        years.append(0) // Use 0 for empty input
        
        for var year = currentYear; year >= 1964; year-- {
            years.append(year)
        }
        
        graduationYearPicker.delegate = self
        graduationYearPicker.dataSource = self
    }
    
    // Mark: UIPickerView Delegate / Data Source functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if (years[row] == 0) {
                return "---" // Show blank option as "---"
            }
            else {
                return "\(years[row])"
            }
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[graduationYearPicker.selectedRowInComponent(component)]
        if let block = onYearSelected {
            block(year: year)
        }
        self.year = year
    }
}
