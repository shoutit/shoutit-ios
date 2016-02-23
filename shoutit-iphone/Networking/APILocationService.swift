
//
//  APILocationService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 11/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Alamofire

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
        
        APIManager.manager().request(.PATCH, url, parameters: params, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success(let data):
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let userJson = json as? [String : AnyObject], user = SecureCoder.userWithDictionary(userJson) {
                        Account.sharedInstance.user = user
                        completionHandler(.Success(user))
                    } else {
                        throw ParseError.User
                    }
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        }
    }

}
