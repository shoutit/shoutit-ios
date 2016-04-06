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

class APIMiscService {
    
    private static let categoriesURL = APIManager.baseURL + "/shouts/categories"
    private static let suggestionURL = APIManager.baseURL + "/misc/suggestions"
    private static let currenciesURL = APIManager.baseURL + "/misc/currencies"
    private static let reportURL = APIManager.baseURL + "/misc/reports"
    
    static func requestCategories() -> Observable<[Category]> {
        return APIGenericService.requestWithMethod(.GET, url: categoriesURL, params: NopParams(), encoding: .JSON)
    }
    
    static func requestSuggestionsWithParams(params: SuggestionsParams) -> Observable<Suggestions> {
        return APIGenericService.requestWithMethod(.GET, url: suggestionURL, params: params, encoding: .URL)
    }
    
    static func requestCurrencies() -> Observable<[Currency]> {
        return APIGenericService.requestWithMethod(.GET, url: currenciesURL, params: NopParams(), encoding: .JSON)
    }
    
    static func makeReport(report: Report) -> Observable<[Currency]> {
        return APIGenericService.requestWithMethod(.POST, url: currenciesURL, params: report.encode(), encoding: .JSON)
    }
}