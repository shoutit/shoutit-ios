//
//  APIManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import Reachability
import Kingfisher

final class APIManager {

    #if STAGING
        static let baseURL = "https://dev.api.shoutit.com/v3"
        // runscope url   "https://dev-api-shoutit-com-qm7w6bwy42b2.runscope.net/v3"
        // base dev url "http://dev.api.shoutit.com/v2"
    #elseif LOCAL
        static let baseURL = "http://local.api.shoutit.com/v3"
    #else
        static let baseURL = "https://api.shoutit.com/v3"
    #endif
    
    static func manager() -> Alamofire.Manager {
        if apiManager == nil {
            let defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = defaultHeaders
            apiManager = Alamofire.Manager(configuration: configuration)
        }
        return apiManager!
    }
    
    private static var apiManager: Alamofire.Manager?
    
    // MARK: - Token
    
    static func setAuthToken(token: String, pageId: String?) {
        _setAuthToken(token, pageId: pageId)
    }
    
    static func eraseAuthToken() {
        _setAuthToken(nil, pageId: nil)
    }
    
    private static func _setAuthToken(token: String?, pageId: String?) {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["Authorization"] = token
        defaultHeaders["Authorization-Page-Id"] = pageId
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        apiManager = Alamofire.Manager(configuration: configuration)
        
        KingfisherManager.sharedManager.downloader.requestModifier = {(request: NSMutableURLRequest) in
            var headerFields = request.allHTTPHeaderFields ?? [String : String]()
            headerFields["Authorization"] = token
            request.allHTTPHeaderFields = headerFields
        }
    }
    
    // MARK: - Reachability
    
    static func isNetworkReachable() -> Bool {
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            return reachability.isReachable()
        } catch {
            return false
        }
    }
}

extension Alamofire.Response {
    
    func success(success: (Value) -> Void, failure:(Error) -> Void) {
        switch self.result {
        case .Success(let value):
            success(value)
        case .Failure(let error):
            failure(error)
        }
    }
}
