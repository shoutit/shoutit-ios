//
//  DateFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class DateFormatters {
    
    static let sharedInstance = DateFormatters()
    
    private let formatter: NSDateFormatter
    
    init() {
        formatter = NSDateFormatter()
        
    }
    
    func stringFromDateEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setDayFormat()
        
        return stringFromDate(date)
    }
    
    func stringFromDate(date: NSDate) -> String {
        setDayFormat()
        
        return formatter.stringFromDate(date)
    }
    
    func setDayFormat() {
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    func setHourFormat() {
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
    }
    
    func hourStringFromEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setHourFormat()
        
        return formatter.stringFromDate(date)
    }
}
