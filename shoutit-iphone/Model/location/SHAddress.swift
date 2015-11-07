//
//  SHAddress.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 05/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MapKit
import ObjectMapper
import Haneke

class SHAddress: Mappable {

    private(set) var address: String?
    private(set) var city: String?
    private(set) var country: String?
    private(set) var latitude: Float?
    private(set) var longitude: Float?
    private(set) var postalCode: String?
    private(set) var state: String?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        address         <- map["address"]
        city            <- map["city"]
        country         <- map["country"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
        postalCode      <- map["postal_code"]
        state           <- map["state"]
    }
    
    static func getFromCache() -> SHAddress? {
        var shAddress: SHAddress? = nil
        let semaphore = dispatch_semaphore_create(0)
        getFromCache { (address) -> () in
            shAddress = address
            dispatch_semaphore_signal(semaphore)
        }
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) != 0) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
        return shAddress
    }
    
    static func getFromCache(address: SHAddress -> ()) {
        Shared.stringCache.fetch(key: Constants.Cache.SHAddress)
            .onSuccess({ (cachedString) -> () in
                if let shAddress = Mapper<SHAddress>().map(cachedString) {
                    address(shAddress)
                }
            })
    }
    
}
