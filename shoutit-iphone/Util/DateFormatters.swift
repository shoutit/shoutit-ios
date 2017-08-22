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
    
    fileprivate let formatter: DateFormatter
    fileprivate let apiFormatter: DateFormatter
    
    public init() {
        formatter = DateFormatter()
        apiFormatter = DateFormatter()
    }
    
    public func apiStringFromDate(_ date: Date) -> String {
        setAPIFormat()
        return apiFormatter.string(from: date)
    }
    
    public func setAPIFormat() {
        apiFormatter.dateFormat = "yyyy-MM-dd"
        apiFormatter.locale = Locale(identifier: "en_EN")
    }
    
    public func stringFromDateEpoch(_ epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        
        setDayFormat()
        
        return stringFromDate(date)
    }
    
    public func stringFromDate(_ date: Date) -> String {
        setDayFormat()
        
        return formatter.string(from: date)
    }
    
    public func setDayFormat() {
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    public func setHourFormat() {
        formatter.dateFormat = "HH:mm"
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
    }
    
    public func hourStringFromEpoch(_ epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        
        setHourFormat()
        
        return formatter.string(from: date)
    }
    
    public func dateFromBasicString(_ string: String?) -> Date? {
        guard let string = string else {
            return nil
        }
        
        setAPIFormat()
        
        return formatter.date(from: string)
    }
    
    public func dateFromApiString(_ string: String?) -> Date? {
        guard let string = string else {
            return nil
        }
        
        setAPIFormat()
        
        return apiFormatter.date(from: string)
    }
}
