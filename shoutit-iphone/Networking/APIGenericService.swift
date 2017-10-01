//
//  APIGenericService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import JSONCodable
import RxSwift
import RxCocoa
import ShoutitKit

final class APIGenericService {
    
    static var isRefreshingToken : Bool = false
    static var refreshTokenSubject : PublishSubject<Bool> = PublishSubject()
    static var refreshTokenObservableStore : Observable<Void>?
    static let disposeBag = DisposeBag()
    
    static func basicRequestWithMethod<P: Params>(
        _ method: HTTPMethod,
        url: String,
        params: P?,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil) -> Observable<Void> {
        
        let observable : Observable<Void> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager().request(url, method: method, parameters: params?.params, encoding: encoding, headers: headers)
            
            let cancel = Disposables.create {
                request.cancel()
            }
            
            request
                .validate({ (request, response, data) -> Request.ValidationResult in
                    if (200..<300) ~= response.statusCode {
                        return .success
                    }
                    
                    guard let data = data else {
                        return .success
                    }
                    
                    do {
                        let dataObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                        guard let json = dataObject as? [String : AnyObject], let errorJson = json["error"] else {
                            assertionFailure()
                            return .failure(InternalParseError.invalidJson)
                        }
                    
                    
                        let error = try APIError(object: json)
                        
                        return .failure(error)
                        
                    } catch (let serializationError) {
                        return .failure(serializationError)
                    }
                    
                })
                .response(completionHandler: { (response) in
                    guard let responseData = response.data, responseData.count > 0 else {
                        observer.onNext()
                        observer.onCompleted()
                        return
                    }
                    observer.onNext()
                    observer.onCompleted()
                    
                })
            
            return cancel
        }
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<Void> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<Void> in
                return observable
            })
        }
        
        
        return observable
    }
    
    static func requestWithMethod<P: Params, T: JSONDecodable>(
        _ method: HTTPMethod,
        url: URLConvertible,
        params: P?,
        encoding: ParameterEncoding = URLEncoding.default,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<T> {
        
        let observable : Observable<T> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(url, method: method, parameters: params?.params, encoding: encoding, headers: headers)
            
            let cancel = Disposables.create {
                request.cancel()
            }
            
            debugPrint(request)
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    debugPrint(json)
                    let object: T = try parseJson(json as! JSONObject)
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<T> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<T> in
                return observable
            })
        }
        
        
        return observable
    }
    
    static func requestWithMethod<P: Params, T: JSONDecodable>(
        _ method: HTTPMethod,
        url: URLConvertible,
        params: P?,
        encoding: ParameterEncoding = URLEncoding.default,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<[T]> {
        
        let observable : Observable<[T]> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(url, method: method, parameters: params?.params, encoding: encoding, headers: headers)
            
            let cancel = Disposables.create {
                request.cancel()
            }
            
            debugPrint(request)
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    debugPrint(originalJson)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    let object: [T] = try parseJsonArray(json as! [JSONObject])
                    
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<[T]> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<[T]> in
                return observable
            })
        }
        
        
        return observable
    }
    
    
    static func isTokenValid() -> Bool {
        guard let tokenExpires = APIManager.tokenExpiresAt else {
            return true
            
        }
        let currentTime = Int(Date().timeIntervalSince1970)
        
        print("\(tokenExpires) > \(currentTime)")
        
        return tokenExpires > currentTime
    }
    
    static func startRefreshingToken() {
        print("REFRESH TOKEN")
        
        isRefreshingToken = true
        
        guard let refreshToken =  APIManager.authData?.refreshToken else {
            self.refreshTokenSubject.onNext(true)
            return
        }
        
        
        let params = RefreshTokenParams(refreshToken: refreshToken)
        
        let observable: Observable<AuthData> = APIAuthService.refreshAuthToken(params)
        
        refreshTokenObservableStore = observable.flatMap({ authData -> Observable<Void> in
            
            do {
                try Account.sharedInstance.refreshAuthData(authData)
                return Observable.just(Void())
            } catch let error {
                return Observable.error(error)
            }
        })
        
        refreshTokenObservableStore?.subscribe({ (event) in
            self.isRefreshingToken = false
            switch event {
            case .next(_): self.refreshTokenSubject.onNext(true)
            case .error(let error):
                print(error)
                do {
                    try Account.sharedInstance.logout()
                } catch {
                    assertionFailure("Could not log out user")
                }
            default: break
            }
        }).addDisposableTo(disposeBag)
    
    }
    
    // MARK: - Helpers
    
    static func validateResponseAndExtractJson(_ response: DataResponse<Any>) throws -> AnyObject {
        
        switch response.result {
        case .success:
            if let httpResponse = response.response, (200..<300) ~= httpResponse.statusCode {
                return response.value as AnyObject
            }
            
            guard let json = response.value as? [String : AnyObject], let errorJson = json["error"] as? [String: Any] else {
                assertionFailure()
                throw InternalParseError.invalidJson
            }
            
            let error = try APIError(object: errorJson)
            
            throw error
        case .failure(let error):
            throw error
        }
    }
    
    static func extractJsonFromJson(_ json: AnyObject, withPathComponents components: [String]?) throws -> AnyObject {
        guard let components = components else {
            return json
        }
        
        var nestedJson: AnyObject? = json
        for path in components {
            if let nested = nestedJson as? [String : AnyObject] {
                nestedJson = nested[path]
            }
        }
        guard let j = nestedJson else {
            debugPrint(json)
            assertionFailure(InternalParseError.invalidJson.userMessage)
            throw InternalParseError.invalidJson
        }
        
        return j
    }
    
    static func parseJson<T: JSONDecodable>(_ json: JSONObject, failureExpected: Bool = false) throws -> T {
     
        return try T(object: json)
    }
    
    static func parseJsonArray<T: JSONDecodable>(_ json: [JSONObject]) throws -> [T] {
        
        let t: [T] = try Array<T>(JSONArray: json)
        return t
    }
}


