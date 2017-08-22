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
import RxSwift
import ShoutitKit

final class APIMiscService {
    
    fileprivate static let categoriesURL = APIManager.baseURL + "/shouts/categories"
    fileprivate static let suggestionURL = APIManager.baseURL + "/misc/suggestions"
    fileprivate static let currenciesURL = APIManager.baseURL + "/misc/currencies"
    fileprivate static let reportURL = APIManager.baseURL + "/misc/reports"
    
    static func requestCategories() -> Observable<[ShoutitKit.Category]> {
        return APIGenericService.requestWithMethod(.GET, url: categoriesURL, params: NopParams(), encoding: .json)
    }
    
    static func requestSuggestionsWithParams(_ params: SuggestionsParams) -> Observable<Suggestions> {
        return APIGenericService.requestWithMethod(.GET, url: suggestionURL, params: params, encoding: .url)
    }
    
    static func requestSuggestedUsersWithParams(_ params: SuggestionsParams) -> Observable<PagedResults<Profile>> {
        return requestSuggestionsWithParams(params).map { (suggestions) -> PagedResults<Profile> in
            
            var results : PagedResults<Profile>
            
            if let users = suggestions.users {
                results = PagedResults(users)
            } else {
                results = PagedResults([])
            }
            
            return results
        }
    }
    
    static func requestSuggestedPagesWithParams(_ params: SuggestionsParams) -> Observable<PagedResults<Profile>> {
        return requestSuggestionsWithParams(params).map { (suggestions) -> PagedResults<Profile> in
            
            var results : PagedResults<Profile>
            
            if let users = suggestions.pages {
                results = PagedResults(users)
            } else {
                results = PagedResults([])
            }
            
            return results
        }
    }
    
    static func requestCurrencies() -> Observable<[Currency]> {
        return APIGenericService.requestWithMethod(.GET, url: currenciesURL, params: NopParams(), encoding: .json)
    }
    
    static func geocode(_ params: GeocodeParams) -> Observable<Address> {
        let url = APIManager.baseURL + "/misc/geocode"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url)
    }

    static func makeReport(_ report: Report) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: reportURL, params: report.encode(), encoding: .json)
    }
}
