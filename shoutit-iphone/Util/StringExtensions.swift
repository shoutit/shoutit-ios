//
//  StringExtensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension String {
    
    func toURL() -> NSURL? {
        return NSURL(string: self)
    }
}


extension String {
    var doubleValue: Double {
        let nf = NSNumberFormatter()
        nf.decimalSeparator = "."
        nf.secondaryGroupingSize = 2
        
        if let result = nf.numberFromString(self) {
            return result.doubleValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.numberFromString(self) {
                return result.doubleValue
            }
        }
        return 0
    }
}