//
//  SHDiscoverItemModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import ObjectMapper

class SHDiscoverItem: Mappable {
    
    private(set) var id: String?
    private(set) var api_Url: String?
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var position: Int?
    private(set) var image: String?
    private(set) var icon: String?
    private(set) var description: String?
    private(set) var cover: String?
    private(set) var countries = [String]()
    private(set) var parents = []
    private(set) var children = [SHDiscoverItem]()
    private(set) var shouts_Url: String?
    
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id                 <- map["id"]
        api_Url            <- map["api_url"]
        title              <- map["title"]
        subtitle           <- map["subtitle"]
        position           <- map["position"]
        image              <- map["image"]
        icon               <- map["icon"]
        description        <- map["description"]
        cover              <- map["cover"]
        countries          <- map["countries"]
        parents            <- map["parents"]
        children           <- map["children"]
        shouts_Url         <- map["shouts_Url"]
    }
}
