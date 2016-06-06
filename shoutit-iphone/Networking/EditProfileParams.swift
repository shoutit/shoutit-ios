//
//  EditProfileParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct EditProfileParams: Params {
    
    public let firstname: String?
    public let lastname: String?
    public let name: String?
    public let username: String?
    public let bio: String?
    public let website: String?
    public let location: Address?
    public let imagePath: String?
    public let coverPath : String?
    public let mobile: String?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["first_name"] = firstname
        p["last_name"] = lastname
        p["name"] = name
        p["username"] = username
        p["bio"] = bio
        p["website"] = website
        p["mobile"] = mobile
        if let latitude = location?.latitude, longitude = location?.longitude, address = location?.address {
            p["location"] = ["latitude" : latitude, "longitude" : longitude, "address" : address]
        }
        p["image"] = imagePath
        p["cover"] = coverPath
        
        
        return p
    }
    
    public init(firstname: String?, lastname: String?, name: String?, username: String?, bio: String?, website: String?, location: Address?, imagePath: String?, coverPath: String?, mobile: String?){
        self.firstname = firstname
        self.lastname = lastname
        self.name = name
        self.username = username
        self.bio = bio
        self.website = website
        self.location = location
        self.imagePath = imagePath
        self.coverPath = coverPath
        self.mobile = mobile
    }
}
