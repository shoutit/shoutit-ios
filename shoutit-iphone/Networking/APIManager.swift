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
import AdSupport

final class APIManager {

    #if STAGING
//        static let baseURL = "https://api.shoutit.com/v3"
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
            var defaultHeaders =
                Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
            defaultHeaders["User-Agent"] = "Shoutit Staging/com.appunite.shoutit (42000; OS Version 9.3.2 (Build 13F69))"
            if let deviceId = ASIdentifierManager.shared()?.advertisingIdentifier {
                defaultHeaders["USER_DEVICE_ID"] = deviceId
            }
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
        
        var defaultHeaders = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["Authorization"] = token
        defaultHeaders["Authorization-Page-Id"] = pageId
        defaultHeaders["User-Agent"] = "Shoutit Staging/com.appunite.shoutit (42000; OS Version 9.3.2 (Build 13F69))"
        if let deviceId = ASIdentifierManager.shared()?.advertisingIdentifier {
            defaultHeaders["USER_DEVICE_ID"] = deviceId
        }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        apiManager = Alamofire.SessionManager(configuration: configuration)
        
        let modifier = AnyModifier { request in
            var r = request
            var headerFields = request.allHTTPHeaderFields ?? [String : String]()
            headerFields["Authorization"] = token
            headerFields["User-Agent"] = "Shoutit Staging/com.appunite.shoutit (42000; OS Version 9.3.2 (Build 13F69))"
            if let deviceId = ASIdentifierManager.shared()?.advertisingIdentifier {
                defaultHeaders["USER_DEVICE_ID"] = deviceId
            }
            r.allHTTPHeaderFields = headerFields
            return r
        }
        
        KingfisherManager.shared.defaultOptions = [KingfisherOptionsInfo.Element.requestModifier(modifier)]
    }
    
    // MARK: - Reachability
    
    static func isNetworkReachable() -> Bool {
        do {
            let reachability = try Reachability()
            return reachability?.isReachable ?? true
        } catch {
            return false
        }
    }
}
