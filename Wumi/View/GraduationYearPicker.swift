//
//  GraduationYearPicker.swift
//  Wumi
//
//  Created by Herman on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GraduationYearPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var years = [Int]()
    
    var year: Int = 0 {
        didSet {
            selectRow(self.years.indexOf(self.year)!, inComponent: 0, animated: true)
        }
    }
    
    var onYearSelected: ((year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupYearList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupYearList()
    }
    
    private func setupYearList() {
        let currentYear = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
        
        self.years.append(0) // Use 0 for empty input
        
        for var year = currentYear; year >= 1964; year-- {
            self.years.append(year)
        }
        
        self.delegate = self
        self.dataSource = self
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if (self.years[row] == 0) {
                return "---"
            }
            else {
                return "\(self.years[row])"
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
        let year = self.years[self.selectedRowInComponent(component)]
        if let block = onYearSelected {
            block(year: year)
        }
        
        self.year = year
    }
}
