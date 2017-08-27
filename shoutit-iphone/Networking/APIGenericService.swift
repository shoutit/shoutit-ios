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
        _ method: Alamofire.Method,
        url: String,
        params: P?,
        encoding: ParameterEncoding = .url,
        headers: [String: String]? = nil) -> Observable<Void> {
        
        let observable : Observable<Void> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            
            request.responseData{ (response) in
                guard let responseData = response.data, responseData.count > 0 else {
                    observer.onNext()
                    observer.onCompleted()
                    return
                }
                do {
                    let dataObject = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    print(dataObject)
                    
                    
                    let result : Result<AnyObject, NSError> = Result.success(dataObject)
                    let resp : Response<AnyObject, NSError> = Response(request: response.request, response: response.response, data: responseData, result: result)
                    
                    _ = try validateResponseAndExtractJson(resp)
                    observer.onNext()
                    observer.onCompleted()
                    
                } catch let error {
                    observer.onError(error)
                }
            }
            
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
        encoding: ParameterEncoding = .url,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<T> {
        
        let observable : Observable<T> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
//                    debugPrint(json)
                    let object: T = try parseJson(json)
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
        encoding: ParameterEncoding = .url,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<[T]> {
        
        let observable : Observable<[T]> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    let object: [T] = try parseJsonArray(json)
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
    
    static func validateResponseAndExtractJson(_ response: Response<AnyObject, NSError>) throws -> AnyObject {
        
        switch response.result {
        case .success(let originalJson):
            if let httpResponse = response.response, (200..<300) ~= httpResponse.statusCode {
                return originalJson
            }
            
            guard let json = originalJson as? [String : AnyObject], let errorJson = json["error"] else {
                assertionFailure()
                throw InternalParseError.invalidJson
            }
            
            let decoded: Decoded<APIError> = decode(errorJson)
            switch decoded {
            case .success(let error):
                throw error
            case .failure(let decodeError):
                assertionFailure(decodeError.description)
                throw decodeError
            }
            
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
    
    static func parseJson<T: JSONDecodable>(_ json: AnyObject, failureExpected: Bool = false) throws -> T {
        
        let object = try T(json: json)
        return object
//        let decoded: Decoded<T> = decode(json)
//        switch decoded {
//        case .success(let object):
//            return object
//        case .failure(let decodeError):
//            if !failureExpected {
//                debugPrint(json)
//                assertionFailure("\(decodeError.description) in model of type \(T.self)")
//            }
//            throw decodeError
//        }
    }
    
    static func parseJsonArray<T: JSONDecodable>(_ json: AnyObject) throws -> [T] {
        let object = try T(json: json)
        return object
//        let decoded: Decoded<[T]> = decode(json)
//        switch decoded {
//        case .success(let object):
//            return object
//        case .failure(let decodeError):
//            debugPrint(json)
//            assertionFailure("\(decodeError.description) in model of type \(T.self)")
//            throw decodeError
//        }
    }
}
