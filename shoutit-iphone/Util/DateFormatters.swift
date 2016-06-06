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
    
    public init() {
        formatter = NSDateFormatter()
        
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
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    public func setHourFormat() {
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
    }
    
    public func hourStringFromEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        
        setHourFormat()
        
        return formatter.stringFromDate(date)
    }
}
