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

class APITagsService {
    
    private static let batchTagListenURL = APIManager.baseURL + "/tags/batch_listen"
    
    static func listen(listen: Bool, toTagWithName name: String) -> Observable<Void> {
        let url = APIManager.baseURL + "/tags/\(name)/listen"
        let method: Alamofire.Method = listen ? .POST : .DELETE
        return APIGenericService.basicRequestWithMethod(method, url: url, params: NopParams(), encoding: .URL, headers: nil)
    }
    
    static func retrieveTagWithName(name: String) -> Observable<Tag> {
        let url = APIManager.baseURL + "/tags/\(name)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func retrieveRelatedTagsForTagWithName(name: String, params: RelatedTagsParams) -> Observable<[Tag]> {
        let url = APIManager.baseURL + "/tags/\(name)/related"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func requestBatchListenTagWithParams(params: BatchListenParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: batchTagListenURL, params: params, encoding: .JSON)
    }
}
