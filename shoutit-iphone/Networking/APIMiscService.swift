//
//  APIMiscService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo

class APIMiscService {
    
    private static let categoriesURL = APIManager.baseURL + "/misc/categories"
    private static let suggestionURL = APIManager.baseURL + "/misc/suggestions"
    private static let currenciesURL = APIManager.baseURL + "/misc/currencies"
    
    static func requestCategoriesWithCompletionHandler(completionHandler: Result<[Category], NSError> -> Void) {
        
        APIManager.manager().request(.GET, categoriesURL, parameters: nil, encoding: .JSON, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                
                switch response.result {
                case .Success(let json):
                    do {
                        if let decoded: Decoded<[Category]> = decode(json), categories = decoded.value {
                            completionHandler(.Success(categories))
                        } else {
                            throw ParseError.Categories
                        }
                    } catch let error as NSError {
                        completionHandler(.Failure(error))
                    }
                case .Failure(let error):
                    completionHandler(.Failure(error))
                }
        }
    }
    
    static func requestSuggestionsWithParams(params: SuggestionsParams, withCompletionHandler completionHandler: Result<Suggestions, NSError> -> Void) {
        
        APIManager.manager().request(.GET, suggestionURL, parameters: params.params, encoding: .URL, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                do {
                    if let decoded: Decoded<Suggestions> = decode(json), let suggestions = decoded.value {
                        completionHandler(.Success(suggestions))
                    } else {
                        throw ParseError.Suggestions
                    }
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    static func requestCurrenciesWithCompletionHandler(completionHandler: Result<[Currency], NSError> -> Void) {
        
        APIManager.manager().request(.GET, currenciesURL, parameters: nil, encoding: .JSON, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                
                switch response.result {
                case .Success(let json):
                    do {
                        if let decoded: Decoded<[Currency]> = decode(json), categories = decoded.value {
                            completionHandler(.Success(categories))
                        } else {
                            throw ParseError.Currency
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