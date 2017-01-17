//
//  GraduationYearPickerView.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GraduationYearPickerView: UIView {
    
    /// UIPickerView for selecting graduation.
    private var graduationYearPicker: UIPickerView = UIPickerView()
    /// Internal toolbar on top of view.
    private var toolBar: UIToolbar = UIToolbar()
    /// Current year based on NSCalendar.
    private lazy var currentYear = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
    /// Array of selectable years.
    private lazy var years = [Int]()
    
    /// GraduationYearPicker delegate
    var delegate: GraduationYearPickerDelegate?
    /// Launch textfield
    var launchTextField: UITextField?
    /// Current selected year
    var year: Int = 0 {
        didSet {
            self.graduationYearPicker.selectRow(self.years.indexOf(self.year)!, inComponent: 0, animated: true)
        }
    }
    
    // Closures passed in from caller. These closures are used by callers to define view behaviors
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setProperty()
        self.setupYearList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
        self.setupYearList()
    }
    
    // MARK: Draw view
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.toolBar.tintColor = Constants.General.Color.ThemeColor
    }
    
    override func drawRect(rect: CGRect) {
        // Set up top toolbar
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .Plain,
                                                            target: self,
                                                            action: #selector(self.cancel))
        let confirmButton: UIBarButtonItem = UIBarButtonItem(title: "Confirm",
                                                             style: .Plain,
                                                             target: self,
                                                             action: #selector(self.confirm))
        let flexibleSpaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
                                                                    target: nil,
                                                                    action: nil)
        self.toolBar.items = [cancelButton, flexibleSpaceBarItem, confirmButton]
        
        // Set up UIPickerView
        self.graduationYearPicker.backgroundColor = UIColor.whiteColor()
        
        // Add toolbar and UIPickerView into a stackView
        let stackView = UIStackView(arrangedSubviews: [toolBar, graduationYearPicker])
        stackView.alignment = .Fill
        stackView.axis = .Vertical
        stackView.distribution = .EqualSpacing
        stackView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        addSubview(stackView)
    }
    
    // MARK: Actions
    
    /**
     Action when clicking Cancel bar button.
     */
    func cancel() {
        guard let delegate = self.delegate, cancelSelection = delegate.cancelSelection else { return }
        
        cancelSelection(self, launchTextField: self.launchTextField)
        self.removeFromSuperview()
    }
    
    /**
     Action when clicking Confirm bar button.
     */
    func confirm() {
        guard let delegate = self.delegate, confirmSelection = delegate.confirmSelection else { return }
        
        confirmSelection(self, launchTextField: self.launchTextField)
        self.removeFromSuperview()
    }
    
    // MARK: Help functions
    
    // Set up picker year list
    private func setupYearList() {
        self.years.append(0) // Use 0 for empty input
        
        for year in (1964...self.currentYear).reverse() {
            self.years.append(year)
        }
        
        self.graduationYearPicker.delegate = self
        self.graduationYearPicker.dataSource = self
    }
    
    /**
     Show graduation year in picker.
     
     - Parameters:
        - year: Year number to be shown.
     
     - Return:
        String to be shown in picker for this year.
     */
    class func showGraduationString(year: Int) -> String {
        if year == 0 {
            return ""
        }
        else {
            return "\(year)"
        }
    }
}

// Mark: UIPickerView delegate & data source

extension GraduationYearPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            guard let year = self.years[safe: row] else { return nil }
            if (year == 0) {
                return "---" // Show blank option as "---"
            }
            else {
                return "\(year)"
            }
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.years.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let year = self.years[safe: self.graduationYearPicker.selectedRowInComponent(component)] else { return }
        self.year = year
        
        if let delegate = self.delegate, yearSelection = delegate.onYearSelected {
            yearSelection(self, launchTextField: self.launchTextField, Year: year)
        }
    }
}

// MARK: GraduationYearPickerDelegate

@objc protocol GraduationYearPickerDelegate {
    /** 
     Action when a year is selected.
     
     - Parameters:
        - picker: GraduationYearPickerView being used.
        - launchTextField: UItextfield launches the picker.
        - year: Year selected.
     */
    optional func onYearSelected(picker: GraduationYearPickerView, launchTextField: UITextField?, Year year: Int)
    
    /**
     Action when confirm button is clicked.
     
     - Parameters:
        - picker: GraduationYearPickerView being used.
        - launchTextField: UItextfield launches the picker.
     */
    optional func confirmSelection(picker: GraduationYearPickerView, launchTextField: UITextField?)
    
    /**
     Action when cancel button is clicked.
     
     - Parameters:
        - picker: GraduationYearPickerView being used.
        - launchTextField: UItextfield launches the picker.
     */
    optional func cancelSelection(picker: GraduationYearPickerView, launchTextField: UITextField?)
}
