//
//  Promotion.swift
//  shoutit
//
//  Created by Piotr Bernad on 15/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Promotion: Decodable {
    let id: String
    let isExpired:  Bool
    let label: PromotionLabel?
    
    static func decode(j: JSON) -> Decoded<Promotion> {
        return curry(Promotion.init)
            <^> j <| "id"
            <*> j <| "is_expired"
            <*> j <|? "label"
        
    }
 
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

struct PromotionLabel: Decodable {
    let name : String
    let description: String
    let color: String
    let backgroundColor: String
    
    static func decode(j: JSON) -> Decoded<PromotionLabel> {
        return curry(PromotionLabel.init)
            <^> j <| "name"
            <*> j <| "description"
            <*> j <| "color"
            <*> j <| "bg_color"
    }
}