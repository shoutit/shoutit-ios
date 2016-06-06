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
    
    private static let categoriesURL = APIManager.baseURL + "/shouts/categories"
    private static let suggestionURL = APIManager.baseURL + "/misc/suggestions"
    private static let currenciesURL = APIManager.baseURL + "/misc/currencies"
    private static let reportURL = APIManager.baseURL + "/misc/reports"
    
    static func requestCategories() -> Observable<[ShoutitKit.Category]> {
        return APIGenericService.requestWithMethod(.GET, url: categoriesURL, params: NopParams(), encoding: .JSON)
    }
    
    static func requestSuggestionsWithParams(params: SuggestionsParams) -> Observable<Suggestions> {
        return APIGenericService.requestWithMethod(.GET, url: suggestionURL, params: params, encoding: .URL)
    }
    
    static func requestSuggestedUsersWithParams(params: SuggestionsParams) -> Observable<PagedResults<Profile>> {
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
    
    static func requestSuggestedPagesWithParams(params: SuggestionsParams) -> Observable<PagedResults<Profile>> {
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
        return APIGenericService.requestWithMethod(.GET, url: currenciesURL, params: NopParams(), encoding: .JSON)
    }
    
    static func geocode(params: GeocodeParams) -> Observable<Address> {
        let url = APIManager.baseURL + "/misc/geocode"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }

    static func makeReport(report: Report) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: reportURL, params: report.encode(), encoding: .JSON)
    }
}