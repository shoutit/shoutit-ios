//
//  NumberFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class NumberFormatters {
    
    static func minutesAndSecondsUserDisplayableStringWithTimeInterval(time: NSTimeInterval) -> String {
        let seconds = Int(time)
        let minutesPart = seconds / 60
        let secondsPart = seconds % 60
        let minutesString = localizedNumber(minutesPart, numberOfDigits: 2)
        let secondsString = localizedNumber(secondsPart, numberOfDigits: 2)
        return "\(minutesString):\(secondsString)"
    }
    
    static func numberToShortString(number: Int) -> String {
        
        var num:Double = Double(number)
        
        num = fabs(num);
        
        if (num < 1000.0){
            return localizedNumber(Int(num))
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        let units:[String] = [NSLocalizedString("K", comment: ""),
                              NSLocalizedString("M", comment: ""),
                              "G",
                              "T",
                              "P",
                              "E"];
        
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        let string = "\(localizedNumber(Int(roundedNum)))\(units[exp-1])"
        return string
    }
    
    static func priceStringWithPrice(price: Int?, currency: String? = nil) -> String? {
        
        guard let price = price else {
            return nil
        }
        
        if price == 0 {
            return NSLocalizedString("FREE", comment: "")
        }
        
        let formatter = NSNumberFormatter()
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = .autoupdatingCurrentLocale()
        
        if let currency = currency {
            formatter.currencyCode = currency.lowercaseString
            formatter.numberStyle = .CurrencyStyle
        }
        
        return formatter.stringFromNumber(Double(price)/100.0)
    }
    
    static func badgeCountStringWithNumber(number: Int) -> String {
        
        if number > 99 {
            return "\(NSLocalizedString("+99", comment: "More than 99 Notifications")) "
        }
        
        return localizedNumber(number)
    }
    
    private static func localizedNumber(number: Int, numberOfDigits: Int? = nil) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .NoStyle
        formatter.locale = .autoupdatingCurrentLocale()
        if let numberOfDigits = numberOfDigits {
            formatter.minimumIntegerDigits = numberOfDigits
            formatter.maximumIntegerDigits = numberOfDigits
        }
        
        return formatter.stringFromNumber(number)!
    }
}