//
//  DateFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

public final class DateFormatters {
    
    public static let sharedInstance = DateFormatters()
    
    private let formatter: NSDateFormatter
    private let apiFormatter: NSDateFormatter
    
    public init() {
        formatter = NSDateFormatter()
        apiFormatter = NSDateFormatter()
    }
    
    public func apiStringFromDate(date: NSDate) -> String {
        setAPIFormat()
        return apiFormatter.stringFromDate(date)
    }
    
    public func setAPIFormat() {
        apiFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func stringFromDateEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setDayFormat()
        
        return stringFromDate(date)
    }
    
    public func stringFromDate(date: NSDate) -> String {
        setDayFormat()
        
        return formatter.stringFromDate(date)
    }
    
    public func setDayFormat() {
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    public func setHourFormat() {
        formatter.dateFormat = "HH:mm"
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
    }
    
    public func hourStringFromEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setHourFormat()
        
        return formatter.stringFromDate(date)
    }
    
    public func dateFromBasicString(string: String?) -> NSDate? {
        guard let string = string else {
            return nil
        }
        
        setAPIFormat()
        
        return formatter.dateFromString(string)
    }
}
