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
import ShoutitKit

final class APIManager {

    #if STAGING
        static let baseURL = "https://dev-api-shoutit-com-qm7w6bwy42b2.runscope.net/v3"
        // runscope url   "https://dev-api-shoutit-com-qm7w6bwy42b2.runscope.net/v3"
        // base dev url "http://dev.api.shoutit.com/v2"
    #elseif LOCAL
        static let baseURL = "http://local.api.shoutit.com/v3"
    #else
        static let baseURL = "https://api.shoutit.com/v3"
    #endif
    
    static var tokenExpiresAt : Int?
    static var authData : AuthData?
    
    static func manager() -> Alamofire.SessionManager {
        if apiManager == nil {
            let defaultHeaders = Alamofire.SessionManager.sharedInstance.session.configuration.httpAdditionalHeaders ?? [:]
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = defaultHeaders
            apiManager = Alamofire.SessionManager(configuration: configuration)
        }
        return apiManager!
    }
    
    fileprivate static var apiManager: Alamofire.SessionManager?
    
    // MARK: - Token
    
    static func setAuthToken(_ token: String, expiresAt: Int?, pageId: String?) {
        _setAuthToken(token, expiresAt: expiresAt, pageId: pageId)
    }
    
    static func eraseAuthToken() {
        _setAuthToken(nil, expiresAt: nil, pageId: nil)
    }
    
    fileprivate static func _setAuthToken(_ token: String?, expiresAt: Int?, pageId: String?) {
        self.tokenExpiresAt = expiresAt
        
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["Authorization"] = token
        defaultHeaders["Authorization-Page-Id"] = pageId
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
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
