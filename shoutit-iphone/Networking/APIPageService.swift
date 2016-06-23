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
}