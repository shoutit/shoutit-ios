//
//  SHApiManager.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiManager: NSObject {

    static let sharedInstance = SHApiManager()
    
    // Base Urls
    #if DEBUG
    let BASE_URL = "http://dev.api.shoutit.com/v2"
    #else
    let BASE_URL = "https://api.shoutit.com/v2"
    #endif
    
    private override init() {
        // Private initialization to ensure just one instance is created.
    }
    
    func get(url: String, params: [String : AnyObject]?, completionHandler: Response<AnyObject, NSError> -> Void) {
        NetworkActivityManager.addActivity()
        let request = Alamofire.request(.GET, url, parameters: params, headers: authHeaders())
        request.responseJSON { (response) -> Void in
            NetworkActivityManager.removeActivity()
            switch (response.result) {
            case .Success(let result):
                log.debug("Success get request : \(result)")
            case .Failure(let error):
                log.debug("error with get request : \(error)")
            }
            completionHandler(response)
        }
    }
    
    func post(url: String, params: [String : AnyObject]?, completionHandler: Response<AnyObject, NSError> -> Void) {
        NetworkActivityManager.addActivity()
        let request = Alamofire.request(.POST, url, parameters: params, headers: authHeaders())
        request.validate()
            .responseJSON { (response) -> Void in
                NetworkActivityManager.removeActivity()
                switch (response.result) {
                case .Success(let result):
                    log.debug("Success post request : \(result)")
                case .Failure(let error):
                    log.debug("error with post request : \(error)")
                }
                completionHandler(response)
        }
    }
    
    private func authHeaders() -> [String: String]? {
//        if let authToken = NSUserDefaults.standardUserDefaults().getAuthToken() {
//            return [
//                // Headers
//                // "X-API-TOKEN": authToken
//            ]
//        }
        return nil;
    }
    
}
