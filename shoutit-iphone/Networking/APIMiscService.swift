//
//  APIMiscService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import PureJsonSerializer

class APIMiscService {
    
    private static let categoriesURL = APIManager.baseURL + "/misc/categories"
    private static let suggestionURL = APIManager.baseURL + "/misc/suggestions"
    
    static func requestCategoriesWithCompletionHandler(completionHandler: Result<[Category], NSError> -> Void) {
        
        APIManager.manager.request(.GET, categoriesURL, parameters: nil, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData({ (response) in
            switch response.result {
            case .Success(let data):
                do {
                    let json = try Json.deserialize(data)
                    let categories = try [Category](js: json)
                    completionHandler(.Success(categories))
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        })
    }
    
    static func requestSuggestionsWithParams(params: SuggestionsParams withCompletionHandler: Result<[], NSError> -> Void) {
        
    }
}