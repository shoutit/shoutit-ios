
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
                    guard let userJson = json as? [String : AnyObject] else {
                        throw InternalParseError.User
                    }
                    
                    let docodedLogged: Decoded<LoggedUser> = Argo.decode(userJson)
                    let loggedUser: LoggedUser? = docodedLogged.value
                    
                    let docodedGuest: Decoded<GuestUser> = Argo.decode(userJson)
                    let guestUser: GuestUser? = docodedGuest.value
                    
                    Account.sharedInstance.guestUser = guestUser
                    Account.sharedInstance.loggedUser = loggedUser
                    
                    if guestUser == nil && loggedUser == nil {
                        throw InternalParseError.User
                    } else {
                        completionHandler(.Success(guestUser ?? loggedUser!))
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
