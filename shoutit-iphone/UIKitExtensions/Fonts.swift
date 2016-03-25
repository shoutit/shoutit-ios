//
//  Fonts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum FontWeight {
    case Light
    case Regular
    case Medium
    case Semibold
    case Bold
    
    var fontName: String {
        switch self {
        case .Light:
            return "HelveticaNeue-Light"
        case .Regular:
            return "HelveticaNeue"
        case Medium:
            return "HelveticaNeue-Medium"
        case Semibold:
            return "HelveticaNeue-Medium"
        case Bold:
            return "HelveticaNeue-Bold"
        }
    }
    
    @available(iOS 8.2, *)
    var weight: CGFloat {
        switch self {
        case .Light:
            return UIFontWeightLight
        case .Regular:
            return UIFontWeightRegular
        case Medium:
            return UIFontWeightMedium
        case Semibold:
            return UIFontWeightSemibold
        case Bold:
            return UIFontWeightBold
        }
    }
}

extension UIFont {
    
    static func sh_systemFontOfSize(size: CGFloat, weight: FontWeight) -> UIFont {
        
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: weight.weight)
        } else {
            return UIFont(name: weight.fontName, size: size)!
        }
    }
}
