//
//  PromotionOption.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct PromotionOption: Decodable {
    public let id: String
    public let name: String
    public let credits: Int
    public let days: Int?
    public let label: PromotionLabel
    
    public static func decode(j: JSON) -> Decoded<PromotionOption> {
        return curry(PromotionOption.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <| "credits"
            <*> j <|? "days"
            <*> j <| "label"
        
    }
}