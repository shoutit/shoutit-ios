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
import ShoutitKit

final class APIShoutsService {
    
    fileprivate static let shoutsURL = APIManager.baseURL + "/shouts"
    
    static func listShoutsWithParams(_ params: FilteredShoutsParams) -> Observable<PagedResults<Shout>> {
        return APIGenericService.requestWithMethod(.get, url: shoutsURL, params: params, encoding: URLEncoding.default)
    }
    
    static func listCategories() -> Observable<[ShoutitKit.Category]> {
        let url = APIManager.baseURL + "/shouts/categories"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default)
    }
    
    static func retrieveShoutWithId(_ id: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams())
    }
    
    static func deleteShoutWithId(_ id: String) -> Observable<Void> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.basicRequestWithMethod(.delete, url: url, params: NopParams())
    }
    
    static func getAutocompletionWithParams(_ params: AutocompletionParams) -> Observable<[AutocompletionTerm]> {
        let url = shoutsURL + "/autocomplete"
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default)
    }
    
    static func relatedShoutsWithParams(_ params: RelatedShoutsParams) -> Observable<PagedResults<Shout>> {
        let url = shoutsURL + "/\(params.shout.id)/related"
        return APIGenericService.requestWithMethod(.get, url: url,
                                                   params: params,
                                                   encoding: URLEncoding.default,
                                                   headers: ["Accept": "application/json"])
    }

    static func createShoutWithParams(_ params: Argo.JSON) -> Observable<Shout> {
        return APIGenericService.requestWithMethod(.post, url: shoutsURL, params: params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func updateShoutWithParams(_ params: Argo.JSON, uid: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(uid)"
        return APIGenericService.requestWithMethod(.patch, url: url, params: params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func retrievePhoneNumberForShoutWithId(_ id: String) -> Observable<Mobile> {
        let url = shoutsURL + "/\(id)/call"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func getSortTypes() -> Observable<[SortType]> {
        let url = shoutsURL + "/sort_types"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func getPromotionLabels() -> Observable<[PromotionLabel]> {
        let url = shoutsURL + "/promote_labels"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func getPromotionOptions() -> Observable<[PromotionOption]> {
        let url = shoutsURL + "/promote_options"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func promoteShout(_ params: PromoteShoutParams) -> Observable<Promotion> {
        let url = shoutsURL + "/\(params.shout.id)/promote"
        return APIGenericService.requestWithMethod(.patch, url: url, params: params, encoding: JSONEncoding.default, responseJsonPath: ["promotion"], headers: ["Accept": "application/json"])
    }
    

    static func getBookmarkedShouts(_ profile: Profile, params: PageParams) -> Observable<PagedResults<Shout>> {
        let url = APIManager.baseURL + "/profiles/\(profile.username)/bookmarks"
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func bookmarkShout(_ shout: Shout) -> Observable<Success> {
        let url = APIManager.baseURL + "/shouts/\(shout.id)/bookmark"
        return APIGenericService.requestWithMethod(.post, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func removeFromBookmarksShout(_ shout: Shout) -> Observable<Success> {
        let url = APIManager.baseURL + "/shouts/\(shout.id)/bookmark"
        return APIGenericService.requestWithMethod(.delete, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func likeShout(_ shout: Shout) -> Observable<Success> {
        let url = shoutsURL + "/\(shout.id)/like"
        return APIGenericService.requestWithMethod(.post, url: url, params: NopParams(), encoding: URLEncoding.default, responseJsonPath: nil, headers: ["Accept": "application/json"])
    }
    
    static func unlikeShout(_ shout: Shout) -> Observable<Success>{
        let url = shoutsURL + "/\(shout.id)/like"
        return APIGenericService.requestWithMethod(.delete, url: url, params: NopParams(), encoding: URLEncoding.default, responseJsonPath: nil, headers: ["Accept": "application/json"])

    }
    
}
