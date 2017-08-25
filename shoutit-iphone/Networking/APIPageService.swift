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
import Alamofire

final class APIPageService {
    
    static func getPagesWithParams(_ params: FilteredPagesParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func getAdminsForPageWithUsername(_ username: String, pageParams params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/pages/\(username)/admins"
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func addProfileAsAdminWithParams(_ params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Success> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.requestWithMethod(.post, url: url, params: params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func removeProfileAsAdminWithParams(_ params: ProfileIdParams, toPageWithUsername username: String) -> Observable<Success> {
        let url = APIManager.baseURL + "/pages/\(username)/admin"
        return APIGenericService.requestWithMethod(.delete, url: url, params: params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func getPageCategories() -> Observable<[PageCategory]> {
        let url = APIManager.baseURL + "/pages/categories"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func createPage(_ params: PageCreationParams) -> Observable<DetailedPageProfile> {
        let url = APIManager.baseURL + "/pages"
        return APIGenericService.requestWithMethod(.post, url: url, params: params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
    }
    
    static func verifyPage(_ params: PageVerificationParams, forPageWithUsername username: String) -> Observable<PageVerification> {
        let url = APIManager.baseURL + "/pages/\(username)/verification"
        return APIGenericService.requestWithMethod(.post, url: url, params: params, encoding: JSONEncoding.default)
    }
    
    static func getPageVerificationStatus(_ username: String) -> Observable<PageVerification> {
        let url = APIManager.baseURL + "/pages/\(username)/verification"
        return APIGenericService.requestWithMethod(.post, url: url, params: NopParams(), encoding: JSONEncoding.default)
    }

}
