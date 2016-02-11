
//
//  APILocationService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 11/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import PureJsonSerializer

class APILocationService {
    private static let usersURL = APIManager.baseURL + "/users/*"
    
    static func updateLocation(userName: String, coordinates: CLLocationCoordinate2D, completionHandler: Result<User, NSError> -> Void) {
        
        let url = usersURL.stringByReplacingOccurrencesOfString("*", withString: userName)
        
        let params: [String: AnyObject] = [
            "location" : [
                "latitude": coordinates.latitude,
                "longitude": coordinates.longitude
            ]
        ]
        
        APIManager.manager.request(.POST, url, parameters: params, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success(let data):
                do {
                    let json = try Json.deserialize(data)
                    let user = try User(js: json)
                    completionHandler(.Success(user))
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        }
    }

}
