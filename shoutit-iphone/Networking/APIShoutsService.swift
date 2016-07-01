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
    
    private static let shoutsURL = APIManager.baseURL + "/shouts"
    
    static func listShoutsWithParams(params: FilteredShoutsParams) -> Observable<[Shout]> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func searchShoutsWithParams(params: FilteredShoutsParams) -> Observable<PagedResults<Shout>> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL)
    }
    
    static func listCategories() -> Observable<[ShoutitKit.Category]> {
        let url = APIManager.baseURL + "/shouts/categories"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func retrieveShoutWithId(id: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams())
    }
    
    static func deleteShoutWithId(id: String) -> Observable<Void> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.basicRequestWithMethod(.DELETE, url: url, params: NopParams())
    }
    
    static func getAutocompletionWithParams(params: AutocompletionParams) -> Observable<[AutocompletionTerm]> {
        let url = shoutsURL + "/autocomplete"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func relatedShoutsWithParams(params: RelatedShoutsParams) -> Observable<PagedResults<Shout>> {
        let url = shoutsURL + "/\(params.shout.id)/related"
        return APIGenericService.requestWithMethod(.GET, url: url,
                                                   params: params,
                                                   encoding: .URL,
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
    
    static func getSortTypes() -> Observable<[SortType]> {
        let url = shoutsURL + "/sort_types"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func getPromotionLabels() -> Observable<[PromotionLabel]> {
        let url = shoutsURL + "/promote_labels"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func getPromotionOptions() -> Observable<[PromotionOption]> {
        let url = shoutsURL + "/promote_options"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func promoteShout(params: PromoteShoutParams) -> Observable<Promotion> {
        let url = shoutsURL + "/\(params.shout.id)/promote"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON, responseJsonPath: ["promotion"], headers: ["Accept": "application/json"])
    }
    

    static func getBookmarkedShouts(profile: Profile, params: PageParams) -> Observable<PagedResults<Shout>> {
        let url = APIManager.baseURL + "/profiles/\(profile.username)/bookmarks"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func bookmarkShout(shout: Shout) -> Observable<Success> {
        let url = APIManager.baseURL + "/shouts/\(shout.id)/bookmark"
        return APIGenericService.requestWithMethod(.POST, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func removeFromBookmarksShout(shout: Shout) -> Observable<Success> {
        let url = APIManager.baseURL + "/shouts/\(shout.id)/bookmark"
        return APIGenericService.requestWithMethod(.POST, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func likeShout(shout: Shout) -> Observable<Success> {
        let url = shoutsURL + "/\(shout.id)/like"
        return APIGenericService.requestWithMethod(.POST, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil, headers: ["Accept": "application/json"])
    }
    
    static func unlikeShout(shout: Shout) -> Observable<Success>{
        let url = shoutsURL + "/\(shout.id)/like"
        return APIGenericService.requestWithMethod(.DELETE, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil, headers: ["Accept": "application/json"])

    }
    
}