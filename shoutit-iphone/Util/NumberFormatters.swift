//
//  NumberFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public final class NumberFormatters {
    
    public static func minutesAndSecondsUserDisplayableStringWithTimeInterval(_ time: TimeInterval) -> String {
        let seconds = Int(time)
        let minutesPart = seconds / 60
        let secondsPart = seconds % 60
        let minutesString = localizedNumber(minutesPart, numberOfDigits: 2)
        let secondsString = localizedNumber(secondsPart, numberOfDigits: 2)
        return "\(minutesString):\(secondsString)"
    }
    
    public static func numberToShortString(_ number: Int) -> String {
        
        var num:Double = Double(number)
        
        num = fabs(num);
        
        if (num < 1000.0){
            return localizedNumber(Int(num))
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        let units:[String] = ["K",
                              "M",
                              "G",
                              "T",
                              "P",
                              "E"];
        
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        let string = "\(localizedNumber(Int(roundedNum)))\(units[exp-1])"
        return string
    }
    
    public static func priceStringWithPrice(_ price: Int?, currency: String? = nil) -> String? {
        
        guard let price = price else {
            return nil
        }
        
        if price == 0 {
            return NSLocalizedString("FREE", comment: "Free Price")
        }
        
        let formatter = NumberFormatter()
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = .autoupdatingCurrent
        
        if let currency = currency {
            formatter.currencyCode = currency.lowercased()
            formatter.numberStyle = .currency
        }
        
        return formatter.string(from: NSNumber(value: Double(price)/100.0))
    }
    
    public static func badgeCountStringWithNumber(_ number: Int) -> String {
        
        if number > 99 {
            return "\(NSLocalizedString("+99", comment: "More than 99 Notifications")) "
        }
        
        return localizedNumber(number)
    }
    
    fileprivate static func localizedNumber(_ number: Int, numberOfDigits: Int? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.locale = .autoupdatingCurrent
        if let numberOfDigits = numberOfDigits {
            formatter.minimumIntegerDigits = numberOfDigits
            formatter.maximumIntegerDigits = numberOfDigits
        }
        
        return formatter.string(from: NSNumber(value: Int(number)))!
    }
}
