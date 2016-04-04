//
//  APIShoutsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import RxCocoa

class APIShoutsService {
    
    private static let shoutsURL = APIManager.baseURL + "/shouts"
    
    static func listShoutsWithParams(params: FilteredShoutsParams) -> Observable<[Shout]> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func searchShoutsWithParams(params: FilteredShoutsParams) -> Observable<PagedResults<Shout>> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL)
    }
    
    static func listCategories() -> Observable<[Category]> {
        let url = APIManager.baseURL + "/shouts/categories"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func retrieveShoutWithId(id: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.requestWithMethod(.GET,
                                                   url: url,
                                                   params: NopParams())
    }
    
    static func getAutocompletionWithParams(params: AutocompletionParams) -> Observable<[AutocompletionTerm]> {
        let url = shoutsURL + "/autocomplete"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func relatedShoutsWithParams(params: RelatedShoutsParams) -> Observable<[Shout]> {
        let url = shoutsURL + "/\(params.shout.id)/related"
        return APIGenericService.requestWithMethod(.GET, url: url,
                                                   params: params,
                                                   encoding: .URL,
                                                   responseJsonPath: ["results"],
                                                   headers: ["Accept": "application/json"])
    }


    static func createShoutWithParams(params: Argo.JSON) -> Observable<Shout> {
        return APIGenericService.requestWithMethod(.POST, url: shoutsURL, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
    
    static func updateShoutWithParams(params: Argo.JSON, uid: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(uid)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
    
    static func retrievePhoneNumberForShoutWithId(id: String) -> Observable<Mobile> {
        let url = shoutsURL + "/\(id)/call"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
}