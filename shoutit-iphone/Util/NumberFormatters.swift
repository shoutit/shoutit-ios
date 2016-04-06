//
//  NumberFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class NumberFormatters {
    
    static let sharedInstance = NumberFormatters()
    
    func numberToShortString(number: Int) -> String {
        
        var num:Double = Double(number)
        
        let sign = ((num < 0) ? "-" : "" );
        
        num = fabs(num);
        
        if (num < 1000.0){
            return "\(sign)\(Int(num))";
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        let units:[String] = ["K","M","G","T","P","E"];
        
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        
        return "\(sign)\(Int(roundedNum))\(units[exp-1])";
    }
    
    static func priceStringWithPrice(price: Int?, currency: String?) -> String? {
        
        guard let price = price, let currency = currency else {
            return nil
        }
        
        if price == 0 {
            return NSLocalizedString("FREE", comment: "")
        }
        
        let major = price / 100
        let minor = price % 100
        if minor > 0 {
            let minorString = String(format: "%\(02)d", minor)
            return "\(major).\(minorString) \(currency)"
        }
        return "\(major) \(currency)"
    }
    
    static func priceStringWithPrice(price: Int?) -> String? {
        
        guard let price = price else {
            return nil
        }
        
        if price == 0 {
            return NSLocalizedString("FREE", comment: "")
        }
        
        let major = price / 100
        let minor = price % 100
        if minor > 0 {
            let minorString = String(format: "%\(02)d", minor)
            return "\(major).\(minorString)"
        }
        return "\(major)"
    }
}