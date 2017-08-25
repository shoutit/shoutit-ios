//
//  APITagsService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import ShoutitKit

final class APITagsService {
    
    fileprivate static let batchTagListenURL = APIManager.baseURL + "/tags/batch_listen"
    
    static func listen(_ listen: Bool, toTagWithSlug slug: String) -> Observable<ListenSuccess> {
        let url = APIManager.baseURL + "/tags/\(slug)/listen"
        let method: Alamofire.Method = listen ? .post : .delete
        return APIGenericService.requestWithMethod(method, url: url, params: NopParams(), encoding: URLEncoding.default, headers: nil)
    }
    
    static func retrieveTagWithSlug(_ slug: String) -> Observable<Tag> {
        let url = APIManager.baseURL + "/tags/\(slug)"
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default)
    }
    
    static func retrieveRelatedTagsForTagWithSlug(_ slug: String, params: RelatedTagsParams) -> Observable<[Tag]> {
        let url = APIManager.baseURL + "/tags/\(slug)/related"
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default, responseJsonPath: ["results"])
    }
    
    static func requestBatchListenTagWithParams(_ params: BatchListenParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.post, url: batchTagListenURL, params: params, encoding: JSONEncoding.default)
    }
}
