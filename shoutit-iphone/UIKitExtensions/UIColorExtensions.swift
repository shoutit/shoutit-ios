//
//  UIColorExtensions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ShoutitColor: Int {
    case PrimaryGreen = 0x4caf50
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
