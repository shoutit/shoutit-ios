//
//  UIColorExtensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ShoutitColor: Int {
    case PrimaryGreen = 0x35dd69
    case ShoutitBlack = 0x1d1d1d
    case ShoutitButtonGreen = 0x4CB950
    case BackgroundWhite = 0xfafafa
    case BackgroundLightGray = 0xF4F4F4
    case BackgroundGrey = 0x333333
    case ShoutGreen = 0xa6d280
    case ShoutRed = 0xca3c3c
    case ShoutDarkGreen = 0x658529
    case MessageBubbleLightGreen = 0x91f261
    case ShoutDetailProfileImageLightGrey = 0xe8e8e8
    case DiscoverBorder = 0xc2c2c2
    case FontGrayColor = 0x646464
    case ButtonBackgroundGray = 0xD6D6D6
    case FontLighterGray = 0x58585A
    case SeparatorGray = 0xe0e0e0
    case ShoutitLightBlueColor = 0x40C4FF
    case CellBackgroundGrayColor = 0xEFEFEF
    case PlaceholderGray = 0x8c8c8c
    case SearchBarGray = 0xf7f7f7
    case SearchBarTextFieldGray = 0xE2E3E6
    case FailureRed = 0xFF5252
    case SuccessGreen = 0x4BA63F
    case LightGreen = 0xC8E6C9
    case TextFieldBorderGrayColor = 0xC3C3C3
    case PromotedShoutYellowBackgroundColor = 0xffd700
    case PromoteActionYellowColor = 0xFFAC40
    
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
    static func colorFromHexAlphaString(hexStringWithAlpha: String) -> UIColor {
        
        let baseString = hexStringWithAlpha.stringByReplacingOccurrencesOfString("#", withString: "")
        
        var alpha, red, blue, green : CGFloat
        
        switch baseString.characters.count {
        case 3:
            alpha = 1.0
            red = colorComponentFrom(baseString, start: 0, length: 1)
            green = colorComponentFrom(baseString, start: 1, length: 1)
            blue = colorComponentFrom(baseString, start: 2, length: 1)
            
        case 4:
            alpha = colorComponentFrom(baseString, start: 0, length: 1)
            red = colorComponentFrom(baseString, start: 1, length: 1)
            green = colorComponentFrom(baseString, start: 2, length: 1)
            blue = colorComponentFrom(baseString, start: 3, length: 1)
        case 6:
            alpha = 1.0
            red = colorComponentFrom(baseString, start: 0, length: 2)
            green = colorComponentFrom(baseString, start: 2, length: 2)
            blue = colorComponentFrom(baseString, start: 4, length: 2)
        case 8:
            alpha = colorComponentFrom(baseString, start: 0, length: 2)
            red = colorComponentFrom(baseString, start: 2, length: 2)
            green = colorComponentFrom(baseString, start: 4, length: 2)
            blue = colorComponentFrom(baseString, start: 6, length: 2)
        default:
            return UIColor.blackColor()
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func colorComponentFrom(string: NSString, start : Int, length : Int) -> CGFloat {
        let subString = string.substringWithRange(NSMakeRange(start, length))
        
        let fullHex : NSString = length == 2 ? subString : ("\(subString)\(subString)" as NSString)
        
        var hexComponent : UInt32 = 0
        
        NSScanner(string: fullHex as String).scanHexInt(&hexComponent)
        
        return CGFloat(CGFloat(hexComponent)/255.0)
    }
}
