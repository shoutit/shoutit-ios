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
    case BackgroundWhite = 0xfafafa
    case BackgroundGrey = 0x333333
    case ShoutGreen = 0xa6d280
    case ShoutRed = 0xca3c3c
    case ShoutDarkGreen = 0x658529
    case MessageBubbleLightGreen = 0x91f261
    case ShoutDetailProfileImageLightGrey = 0xe8e8e8
    case DiscoverBorder = 0xc2c2c2
}

extension UIColor {
    
    convenience init(shoutitColor: ShoutitColor) {
        self.init(hex: shoutitColor.rawValue)!
    }
}
