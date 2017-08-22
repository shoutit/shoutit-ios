//
//  Fonts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum FontWeight {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    var fontName: String {
        switch self {
        case .light:
            return "HelveticaNeue-Light"
        case .regular:
            return "HelveticaNeue"
        case .medium:
            return "HelveticaNeue-Medium"
        case .semibold:
            return "HelveticaNeue-Medium"
        case .bold:
            return "HelveticaNeue-Bold"
        }
    }
    
    @available(iOS 8.2, *)
    var weight: CGFloat {
        switch self {
        case .light:
            return UIFontWeightLight
        case .regular:
            return UIFontWeightRegular
        case .medium:
            return UIFontWeightMedium
        case .semibold:
            return UIFontWeightSemibold
        case .bold:
            return UIFontWeightBold
        }
    }
}

extension UIFont {
    
    static func sh_systemFontOfSize(_ size: CGFloat, weight: FontWeight) -> UIFont {
        
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: weight.weight)
        } else {
            return UIFont(name: weight.fontName, size: size)!
        }
    }
}
