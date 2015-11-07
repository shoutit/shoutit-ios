//
//  SHApiManager.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import CryptoSwift
import Haneke

class SHApiManager: NSObject {

    static var sharedInstance = SHApiManager()
    
    private let cache = Shared.stringCache
    
    // Base Urls
    #if DEBUG
    let BASE_URL = "http://dev.api.shoutit.com/v2"
    #else
    let BASE_URL = "https://api.shoutit.com/v2"
    #endif
    
    private override init() {
        // Private initialization to ensure just one instance is created.
    }
    
    func get<R: Mappable>(url: String, params: [String : AnyObject]?, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.GET, url, parameters: params, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func patch<R: Mappable>(url: String, params: [String : AnyObject]?, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.PATCH, url, parameters: params, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func post<R: Mappable>(url: String, params: [String : AnyObject]?, isCachingEnabled: Bool = true, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.POST, url, parameters: params, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    // MARK - Private
    // TODO if we get user not authenticated/authorized, then we need refresh user's token and resend the request before calling completion handlers
    private func executeRequest<R: Mappable>(request: Request, var cacheKey: String?, cacheResponse: (R -> Void)?, completionHandler: Response<R, NSError> -> Void) {
        NetworkActivityManager.addActivity()
        if cacheResponse != nil {
            if cacheKey == nil {
                cacheKey = getCacheKey(request)
            }
            cache.fetch(key: cacheKey!).onSuccess { (cachedObject) -> () in
                if let mappedObject = Mapper<R>().map(cachedObject) {
                    cacheResponse?(mappedObject)
                }
            }
        }
        request.responseObject { (response: Response<R, NSError>) -> Void in
            NetworkActivityManager.removeActivity()
            switch (response.result) {
            case .Success(let result):
                if let stringResponse = Mapper().toJSONString(result) {
                    self.cache.set(value: stringResponse, key: cacheKey!)
                }
                log.debug("Success post request : \(result)")
            case .Failure(let error):
                log.debug("error with post request : \(error)")
            }
            completionHandler(response)
        }
    }
    
    private func getCacheKey(request: Request) -> String {
        var key: String = ""
        if let urlString = request.request?.URLString {
            key = urlString
        }
        if let method = request.request?.HTTPMethod {
            key = key.stringByAppendingString(method)
        }
        if let bodyMD5 = request.request?.HTTPBody?.md5() {
            if let bodyString = String(data: bodyMD5, encoding: NSUTF8StringEncoding) {
                key = key.stringByAppendingString(bodyString)
            }
        }
        return key
    }
    
    private func authHeaders() -> [String: String]? {
        if let oauthToken = SHOauthToken.getFromCache(), let accessToken = oauthToken.accessToken, let tokenType = oauthToken.tokenType {
            return [
                // Headers
                "Authorization": "\(tokenType) \(accessToken)"
            ]
        }
        return nil;
    }
    
}
