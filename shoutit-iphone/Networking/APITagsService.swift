//
//  APITagsService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import PureJsonSerializer

class APITagsService {
    
    private static let tagListenURL = APIManager.baseURL + "/tags/*/listen"
    
    static func requestListenTagWithName(name: String, withCompletionHandler completionHandler: Result<Bool, NSError> -> Void) {
        
        let url = tagListenURL.stringByReplacingOccurrencesOfString("*", withString: name)
        
        APIManager.manager.request(.POST, url, parameters: nil, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success:
                completionHandler(.Success(true))
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    static func requestListenTagDeleteWithName(name: String, withCompletionHandler completionHandler: Result<Bool, NSError> -> Void) {
        
        let url = tagListenURL.stringByReplacingOccurrencesOfString("*", withString: name)
        
        APIManager.manager.request(.DELETE, url, parameters: nil, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success:
                completionHandler(.Success(true))
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
}
