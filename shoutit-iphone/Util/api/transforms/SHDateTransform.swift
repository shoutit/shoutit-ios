//
//  SHDateTransform.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 22/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHDateTransform: TransformType {
    typealias Object = NSDate
    typealias JSON = Double
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let timeInt = value as? Double {
            return NSDate(timeIntervalSince1970: NSTimeInterval(timeInt))
        }
        return nil
    }
    
    func transformToJSON(value: NSDate?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970)
        }
        return nil
    }
}
