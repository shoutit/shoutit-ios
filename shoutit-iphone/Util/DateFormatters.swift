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
        formatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
    }
    
    func stringFromDateEpoch(epoch: Int) -> String {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(epoch))
        return stringFromDate(date)
    }
    
    func stringFromDate(date: NSDate) -> String {
        return formatter.stringFromDate(date)
    }
}
