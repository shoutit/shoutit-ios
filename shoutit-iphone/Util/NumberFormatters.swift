//
//  NumberFormatters.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class NumberFormatters {
    
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
        formatter.currencyGroupingSeparator = " "
        formatter.locale = NSLocale.systemLocale()
        
        if let currency = currency {
            formatter.currencyCode = currency.lowercaseString
            formatter.numberStyle = .CurrencyStyle
        }
        
        return formatter.stringFromNumber(Double(price)/100.0)
    }
}