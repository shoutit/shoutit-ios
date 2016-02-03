//
//  APIManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import CryptoSwift
import Haneke
import ReachabilitySwift
import Genome

final class APIManager {
    
    // base url
    #if STAGING
    static let baseURL = "http://dev-api-shoutit-com-qm7w6bwy42b2.runscope.net/v2" // some old dev url "http://dev.api.shoutit.com/v2". don't know when to use it ;]
    #else
    static let baseURL = "https://api.shoutit.com/v2"
    #endif
    
    static var manager: Alamofire.Manager = {
        return Alamofire.Manager.sharedInstance
    }()
    
    // MARK: - Token
    
    static func setAuthToken(token: String, tokenType: String) {
        _setAuthToken("\(tokenType) \(token)")
    }
    
    static func eraseAuthToken() {
        _setAuthToken(nil)
    }
    
    private static func _setAuthToken(token: String?) {
        var headers = manager.session.configuration.HTTPAdditionalHeaders ?? [:]
        headers["Authorization"] = token
        manager.session.configuration.HTTPAdditionalHeaders = headers
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
