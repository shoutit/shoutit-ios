//
//  UIColorExtensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ShoutitColor: Int {
    case primaryGreen = 0x35dd69
    case shoutitBlack = 0x1d1d1d
    case shoutitButtonGreen = 0x4CB950
    case backgroundWhite = 0xfafafa
    case backgroundLightGray = 0xF4F4F4
    case backgroundGrey = 0x333333
    case shoutGreen = 0xa6d280
    case shoutRed = 0xca3c3c
    case shoutDarkGreen = 0x658529
    case messageBubbleLightGreen = 0x91f261
    case shoutDetailProfileImageLightGrey = 0xe8e8e8
    case discoverBorder = 0xc2c2c2
    case fontGrayColor = 0x646464
    case buttonBackgroundGray = 0xD6D6D6
    case fontLighterGray = 0x58585A
    case separatorGray = 0xe0e0e0
    case shoutitLightBlueColor = 0x40C4FF
    case cellBackgroundGrayColor = 0xEFEFEF
    case placeholderGray = 0x8c8c8c
    case searchBarGray = 0xf7f7f7
    case searchBarTextFieldGray = 0xE2E3E6
    case failureRed = 0xFF5252
    case successGreen = 0x4BA63F
    case lightGreen = 0xC8E6C9
    case textFieldBorderGrayColor = 0xC3C3C3
    case promotedShoutYellowBackgroundColor = 0xffd700
    case promoteActionYellowColor = 0xFFAC40
    
    var alpha: Float {
        switch self {
        default:
            return 1.0
        }
    }
}

extension UIColor {
    
    convenience init(shoutitColor: ShoutitColor) {
        self.init(hex: shoutitColor.rawValue, alpha: shoutitColor.alpha)!
    }
}

extension UIColor {
    static func colorFromHexAlphaString(_ hexStringWithAlpha: String) -> UIColor {
        
        let baseString = hexStringWithAlpha.replacingOccurrences(of: "#", with: "")
        
        var alpha, red, blue, green : CGFloat
        
        switch baseString.characters.count {
        case 3:
            alpha = 1.0
            red = colorComponentFrom(baseString as NSString, start: 0, length: 1)
            green = colorComponentFrom(baseString as NSString, start: 1, length: 1)
            blue = colorComponentFrom(baseString as NSString, start: 2, length: 1)
            
        case 4:
            alpha = colorComponentFrom(baseString as NSString, start: 0, length: 1)
            red = colorComponentFrom(baseString as NSString, start: 1, length: 1)
            green = colorComponentFrom(baseString as NSString, start: 2, length: 1)
            blue = colorComponentFrom(baseString as NSString, start: 3, length: 1)
        case 6:
            alpha = 1.0
            red = colorComponentFrom(baseString as NSString, start: 0, length: 2)
            green = colorComponentFrom(baseString as NSString, start: 2, length: 2)
            blue = colorComponentFrom(baseString as NSString, start: 4, length: 2)
        case 8:
            alpha = colorComponentFrom(baseString as NSString, start: 0, length: 2)
            red = colorComponentFrom(baseString as NSString, start: 2, length: 2)
            green = colorComponentFrom(baseString as NSString, start: 4, length: 2)
            blue = colorComponentFrom(baseString as NSString, start: 6, length: 2)
        default:
            return UIColor.black
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func colorComponentFrom(_ string: NSString, start : Int, length : Int) -> CGFloat {
        let subString = string.substring(with: NSMakeRange(start, length)) as NSString
        
        let fullHex : NSString = length == 2 ? subString : ("\(subString)\(subString)" as NSString)
        
        var hexComponent : UInt32 = 0
        
        Scanner(string: fullHex as String).scanHexInt32(&hexComponent)
        
        return CGFloat(CGFloat(hexComponent)/255.0)
    }
}
