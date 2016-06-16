//
//  Promotion+Colors.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 15.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

extension Promotion {
    
    func color() -> UIColor {
        guard let colorString = self.label?.color else {
            return UIColor.blackColor()
        }
        
        return UIColor.colorFromHexAlphaString(colorString)
    }
    
    func backgroundUIColor() -> UIColor {
        guard let colorString = self.label?.backgroundColor else {
            return UIColor.blackColor()
        }
        
        return UIColor.colorFromHexAlphaString(colorString)
    }
}

extension PromotionLabel {
    func color() -> UIColor {
        return UIColor.colorFromHexAlphaString(self.color)
    }
    
    func backgroundUIColor() -> UIColor {
        return UIColor.colorFromHexAlphaString(self.backgroundColor)
    }
}