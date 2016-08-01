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
    
    private static let batchTagListenURL = APIManager.baseURL + "/tags/batch_listen"
    
    static func listen(listen: Bool, toTagWithSlug slug: String) -> Observable<ListenSuccess> {
        let url = APIManager.baseURL + "/tags/\(slug)/listen"
        let method: Alamofire.Method = listen ? .POST : .DELETE
        return APIGenericService.requestWithMethod(method, url: url, params: NopParams(), encoding: .URL, headers: nil)
    }
    
    static func retrieveTagWithSlug(slug: String) -> Observable<Tag> {
        let url = APIManager.baseURL + "/tags/\(slug)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func retrieveRelatedTagsForTagWithSlug(slug: String, params: RelatedTagsParams) -> Observable<[Tag]> {
        let url = APIManager.baseURL + "/tags/\(slug)/related"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func requestBatchListenTagWithParams(params: BatchListenParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: batchTagListenURL, params: params, encoding: .JSON)
    }
}
