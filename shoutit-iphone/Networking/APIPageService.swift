//
//  APIPageService.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class APIPageService {
    
    static func getPagesWithParams(params: FilteredPagesParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func getAdminsForPageWithUsername(username: String, pageParams params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages/\(username)/admins"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func addProfileAsAdminWithParams(params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Void> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
    
    static func removeProfileAsAdminWithParams(params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Void> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.basicRequestWithMethod(.DELETE, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
    
    static func getPageCategories() -> Observable<[PageCategory]> {
        let url = APIManager.baseURL + "/pages/categories"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func createPage(params: PageCreationParams) -> Observable<DetailedPageProfile> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
}