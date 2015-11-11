//
//  SHApiUserService.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 07/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiUserService: NSObject {
    
    private let USERS_URL_NAME = SHApiManager.sharedInstance.BASE_URL + "/users/%@"

    func updateLocation(userName: String, latitude: Float, longitude: Float, completionHandler: Response<SHUser, NSError> -> Void) {
        let params: [String: AnyObject] = [
            "location" : [
                "latitude": latitude,
                "longitude": longitude
            ]
        ]
        SHApiManager.sharedInstance.patch(String(format: USERS_URL_NAME, userName), params: params, completionHandler: completionHandler)
    }
    
}
