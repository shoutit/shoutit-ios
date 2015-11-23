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
import ReachabilitySwift

class SHApiManager: NSObject {

    static var sharedInstance = SHApiManager()
    
    private let cache = Shared.stringCache
    
    // Base Urls
//    #if DEBUG
//    let BASE_URL = "http://dev.api.shoutit.com/v2"
    let BASE_URL = "http://dev-api-shoutit-com-qm7w6bwy42b2.runscope.net/v2"
//    #else
//    let BASE_URL = "https://api.shoutit.com/v2"
//    #endif
    
    private override init() {
        // Private initialization to ensure just one instance is created.
    }
    
    func get<R: Mappable>(url: String, params: [String : AnyObject]?, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.GET, url, parameters: params, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func getArray<R: Mappable>(url: String, params: [String : AnyObject]?, cacheKey: String? = nil, cacheResponse: ([R] -> Void)? = nil, completionHandler: Response<[R], NSError> -> Void) {
        let request = Alamofire.request(.GET, url, parameters: params, headers: authHeaders())
        executeRequestForArray(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func patch<R: Mappable>(url: String, params: [String : AnyObject]?, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.PATCH, url, parameters: params, encoding: Alamofire.ParameterEncoding.JSON, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func post<R: Mappable>(url: String, params: [String : AnyObject]?, isCachingEnabled: Bool = true, cacheKey: String? = nil, cacheResponse: (R -> Void)? = nil, completionHandler: Response<R, NSError> -> Void) {
        let request = Alamofire.request(.POST, url, parameters: params, encoding: Alamofire.ParameterEncoding.JSON, headers: authHeaders())
        executeRequest(request, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func isNetworkReachable() -> Bool {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            return reachability.isReachable()
        } catch {
            return false
        }
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
                if let stringResponse = Mapper().toJSONString(result), let apiCacheKey = cacheKey {
                    self.cache.set(value: stringResponse, key: apiCacheKey)
                }
                log.debug("Success request : \(result)")
            case .Failure(let error):
                log.debug("error with request : \(error)")
            }
            completionHandler(response)
        }
    }
    
    private func executeRequestForArray<R: Mappable>(request: Request, var cacheKey: String?, cacheResponse: ([R] -> Void)?, completionHandler: Response<[R], NSError> -> Void) {
        NetworkActivityManager.addActivity()
        if cacheResponse != nil {
            if cacheKey == nil {
                cacheKey = getCacheKey(request)
            }
            cache.fetch(key: cacheKey!).onSuccess { (cachedObject) -> () in
                if let mappedObject = Mapper<R>().mapArray(cachedObject) {
                    cacheResponse?(mappedObject)
                }
            }
        }
        request.responseArray { (response: Response<[R], NSError>) -> Void in
            NetworkActivityManager.removeActivity()
            switch (response.result) {
            case .Success(let result):
                if let stringResponse = Mapper().toJSONString(result), let apiCacheKey = cacheKey {
                    self.cache.set(value: stringResponse, key: apiCacheKey)
                }
                log.debug("Success request : \(result)")
            case .Failure(let error):
                log.debug("error with request : \(error)")
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
