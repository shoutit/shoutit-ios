//
//  DateFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class DateFormatters {
    
    static let sharedInstance = DateFormatters()
    
    private let formatter: NSDateFormatter
    private let apiFormatter: NSDateFormatter
    
    init() {
        formatter = NSDateFormatter()
        apiFormatter = NSDateFormatter()
        
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
    
    func apiStringFromDate(date: NSDate) -> String {
        setAPIFormat()
        
        return apiFormatter.stringFromDate(date)
    }
    
    func setAPIFormat() {
        apiFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func setDayFormat() {
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    func setHourFormat() {
        formatter.dateFormat = "HH:mm"
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
    }
    
    func hourStringFromEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setHourFormat()
        
        return formatter.stringFromDate(date)
    }
    
    func dateFromBasicString(string: String?) -> NSDate? {
        guard let string = string else {
            return nil
        }
        
        setAPIFormat()
        
        return formatter.dateFromString(string)
    }

}
