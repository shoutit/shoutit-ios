//
//  NSDate+Extension.swift
//  Tasty
//
//  Created by Vitaliy Kuzmenko on 17/10/14.
//  http://github.com/vitkuzmenko
//  Copyright (c) 2014 Vitaliy Kuz'menko. All rights reserved.
//

import Foundation

extension Date {
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    public var timeAgoSimple: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            return "\(String(describing: components.year))yr"
        }
        
        if components.month! > 0 {
            return "\(String(describing: components.month))mo"
        }
        
        // TODO: localize for other calanders
        if components.day! >= 7 {
            let value = components.day!/7
            return "\(value)w"
        }
        
        if components.day! > 0 {
            return "\(String(describing: components.day))d"
        }
        
        if components.hour! > 0 {
            return "\(String(describing: components.hour))h"
        }
        
        if components.minute! > 0 {
            return "\(String(describing: components.minute))m"
        }
        
        if components.second! > 0 {
            return "\(String(describing: components.second))s"
        }
        
        return ""
    }
    
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            if components.year! < 2 {
                return "Last year"
            } else {
                return "\(String(describing: components.year)) years ago"
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                return "Last month"
            } else {
                return "\(String(describing: components.month)) months ago"
            }
        }
        
        // TODO: localize for other calanders
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                return "Last week"
            } else {
                return "\(week) weeks ago"
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                return "Yesterday"
            } else  {
                return "\(components.day) days ago"
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return "An hour ago"
            } else {
                return "\(components.hour) hours ago"
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return "A minute ago"
            } else {
                return "\(components.minute) minutes ago"
            }
        }
        
        if components.second! > 0 {
            if components.second! < 5 {
                return "Just now"
            } else {
                return "\(components.second) seconds ago"
            }
        }
        
        return ""
    }
    
    fileprivate func dateComponents() -> DateComponents {
        let calander = Calendar.current
        return (calander as NSCalendar).components([.second, .minute, .hour, .day, .month, .year], from: self, to: Date(), options: [])
    }
    
}
