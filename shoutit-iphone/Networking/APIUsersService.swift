//
//  APIUsersService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import RxCocoa

class APIUsersService {
    
    private static let usersHomeShoutsURL = APIManager.baseURL + "/profiles/me/home"
    
    static func homeShouts(page_size: Int = 20, page: Int = 1) -> Observable<[Shout]> {
        return APIGenericService.requestWithMethod(.GET,
                                                   url: usersHomeShoutsURL,
                                                   params: PageParams(page: page, pageSize: page_size),
                                                   encoding: .URL,
                                                   responseJsonPath: ["results"],
                                                   headers: ["Accept": "application/json"])
    }
    
    static func listen(listen: Bool, toUserWithUsername username: String) -> Observable<Void> {
        let url = APIManager.baseURL + "/profiles/\(username)/listen"
        let method: Alamofire.Method = listen ? .POST : .DELETE
        return APIGenericService.basicRequestWithMethod(method, url: url, params: NopParams(), encoding: .URL, headers: nil)
    }
    
    static func retrieveUserWithUsername(username: String) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
}