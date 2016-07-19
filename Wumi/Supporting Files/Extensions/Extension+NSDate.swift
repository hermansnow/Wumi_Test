//
//  Extension+NSDate.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension NSDate {
    func timeAgo() -> String {
        // Get NSDate components
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day]
        let now = NSDate()
        let earlierDate = now.earlierDate(self)
        let laterDate = now.laterDate(self)
        let components = calendar.components(unitFlags,
                                             fromDate: earlierDate,
                                             toDate: laterDate,
                                             options: [])
        
        // Initialize date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        
        // Return time ago string
        if (components.day >= 1) {
            if (calendar.isDateInYesterday(self)) {
                return "Yesterday " + timeFormatter.stringFromDate(self)
            }
            else {
                return dateFormatter.stringFromDate(self)
            }
        }
        else {
            if (components.hour >= 2) {
                return "\(components.hour) hours ago"
            }
            else if (components.hour == 1) {
                return "An hour ago"
            }
            else if (components.minute >= 2) {
                return "\(components.minute) minutes ago"
            }
            else if (components.minute == 1) {
                return "A minute ago"
            }
            else if (components.second >= 3) {
                return "\(components.second) seconds ago"
            }
            else {
                return "Just now"
            }
        }
    }
}