//
//  EditPageParams.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 11/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct EditPageParams: Params {
    
    public let name: String?
    public let imagePath: String?
    public let about: String?
    public let is_published: Bool?
    public let description: String?
    public let phone: String?
    public let founded: String?
    public let coverPath : String?
    
    public let impressum: String?
    public let overview: String?
    public let mission: String?
    public let general_info: String?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["name"] = name
        p["image"] = imagePath
        p["about"] = about
        p["phone"] = phone
        p["founded"] = founded
        p["impressum"] = impressum
        p["description"] = description
        p["overview"] = overview
        p["mission"] = mission
        p["general_info"] = general_info
        p["cover"] = coverPath
        p["is_published"] = is_published
        
        return p
    }
    
    public init(name: String?, imagePath: String?, about: String?, description: String?, phone: String?, founded: String?, impressum: String?, overview: String?, mission: String?, general_info: String?, coverPath: String?, is_published: Bool?){
        self.name = name
        self.imagePath = imagePath
        self.about = about
        self.description = description
        self.phone = phone
        self.founded = founded
        self.impressum = impressum
        self.overview = overview
        self.mission = mission
        self.general_info = general_info
        self.coverPath = coverPath
        self.is_published = is_published
    }
}
