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
    public let birthday: String?
    public let gender: Gender?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["first_name"] = firstname as AnyObject
        p["last_name"] = lastname as AnyObject
        p["name"] = name as AnyObject
        p["username"] = username as AnyObject
        p["bio"] = bio as AnyObject
        p["website"] = website as AnyObject
        p["mobile"] = mobile as AnyObject
        if let latitude = location?.latitude, let longitude = location?.longitude, let address = location?.address {
            p["location"] = ["latitude" : latitude, "longitude" : longitude, "address" : address] as AnyObject
        }
        p["image"] = imagePath as AnyObject
        p["cover"] = coverPath as AnyObject
        p["birthday"] = birthday as AnyObject
        p["gender"] = (gender != nil ? (gender!.rawValue) as AnyObject : NSNull() as AnyObject)
        
        
        return p
    }
    
    public init(firstname: String?, lastname: String?, name: String?, username: String?, bio: String?, website: String?, location: Address?, imagePath: String?, coverPath: String?, mobile: String?, birthday: String?, gender: Gender?){
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
        self.birthday = birthday
        self.gender = gender
    }
}
