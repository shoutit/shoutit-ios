//
//  Promotion.swift
//  shoutit
//
//  Created by Piotr Bernad on 15/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct Promotion: Decodable {
    public let id: String
    public let days: Int?
    public let isExpired:  Bool
    public let label: PromotionLabel?
    
    public static func decode(j: JSON) -> Decoded<Promotion> {
        return curry(Promotion.init)
            <^> j <| "id"
            <*> j <|? "days"
            <*> j <| "is_expired"
            <*> j <|? "label"
        
    }
}

public struct PromotionLabel: Decodable {
    public let name : String
    public let description: String
    public let color: String
    public let backgroundColor: String
    
    public static func decode(j: JSON) -> Decoded<PromotionLabel> {
        return curry(PromotionLabel.init)
            <^> j <| "name"
            <*> j <| "description"
            <*> j <| "color"
            <*> j <| "bg_color"
    }
}