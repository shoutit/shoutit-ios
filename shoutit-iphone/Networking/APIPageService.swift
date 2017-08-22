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
    
    static func getPagesWithParams(_ params: FilteredPagesParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func getAdminsForPageWithUsername(_ username: String, pageParams params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages/\(username)/admins"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func addProfileAsAdminWithParams(_ params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Success> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func removeProfileAsAdminWithParams(_ params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Success> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.requestWithMethod(.DELETE, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func getPageCategories() -> Observable<[PageCategory]> {
        let url = APIManager.baseURL + "/pages/categories"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func createPage(_ params: PageCreationParams) -> Observable<DetailedPageProfile> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func verifyPage(_ params: PageVerificationParams, forPageWithUsername username: String) -> Observable<PageVerification> {
        let url = APIManager.baseURL + "/pages/\(username)/verification"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .json)
    }
    
    static func getPageVerificationStatus(_ username: String) -> Observable<PageVerification> {
        let url = APIManager.baseURL + "/pages/\(username)/verification"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .json)
    }

}
