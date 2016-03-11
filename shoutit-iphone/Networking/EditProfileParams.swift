//
//  EditProfileParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct EditProfileParams: Params {
    
    let firstname: String?
    let lastname: String?
    let name: String?
    let username: String?
    let bio: String?
    let website: String?
    let location: Address?
    let imagePath: String?
    let coverPath : String?
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["first_name"] = firstname
        p["last_name"] = lastname
        p["name"] = name
        p["username"] = username
        p["bio"] = bio
        p["website"] = website
        if let latitude = location?.latitude, longitude = location?.longitude, address = location?.address {
            p["location"] = ["latitude" : latitude, "longitude" : longitude, "address" : address]
        }
        p["image"] = imagePath
        p["cover"] = coverPath
        
        return p
    }
}
