//
//  APIDiscoverService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import ShoutitKit

typealias DiscoverResult = (mainItem:DiscoverItem?, retrivedItems:[DiscoverItem]?)

final class APIDiscoverService {
    fileprivate static let discoverURL = APIManager.baseURL + "/discover"
    
    static func discoverItemsWithParams(_ params: FilteredDiscoverItemsParams) -> Observable<[DiscoverItem]> {
        return APIGenericService.requestWithMethod(.get, url: discoverURL, params: params, encoding: URLEncoding.default, responseJsonPath: ["results"])
    }
    
    static func discoverItemDetails(forDiscoverItem discoverItem: DiscoverItem) -> Observable<[DiscoverItem]> {
        let url = discoverURL + "/\(discoverItem.id)"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, responseJsonPath: ["results"])
    }

    static func discoverItems(forDiscoverItem discoverItem: DiscoverItem) -> Observable<DetailedDiscoverItem> {
        return APIGenericService.requestWithMethod(.get, url: discoverItem.apiUrl, params: NopParams(), encoding: URLEncoding.default)
    }
}
