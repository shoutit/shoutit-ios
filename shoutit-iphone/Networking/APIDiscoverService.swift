//
//  APIDiscoverService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import Argo

typealias DiscoverResult = (mainItem:DiscoverItem?, retrivedItems:[DiscoverItem]?)

class APIDiscoverService {
    private static let discoverURL = APIManager.baseURL + "/discover"
    
    class func discoverItemsWithParams(params: FilteredDiscoverItemsParams) -> Observable<[DiscoverItem]> {
        return APIGenericService.requestWithMethod(.GET, url: discoverURL, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func discoverItemDetails(forDiscoverItem discoverItem: DiscoverItem) -> Observable<[DiscoverItem]> {
        let url = discoverURL + "/\(discoverItem.id)"
        return APIGenericService.requestWithMethod(.GET, url: url, encoding: .URL, responseJsonPath: ["results"])
    }

    
    static func discoverItems(forDiscoverItem discoverItem: DiscoverItem?) -> Observable<DiscoverResult> {
        return Observable.create({ (observer) -> Disposable in
            
            guard let discover = discoverItem else {
                return AnonymousDisposable {}
            }
            
            APIManager.manager().request(.GET, discover.apiUrl, encoding: .URL, headers: nil).responseData({ (response) -> Void in

                switch response.result {
                case .Success(let data):
                    do {
                        let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        
                        if let j = json, jr = j.objectForKey("children") {
                            
                            var mainItemParsed : DiscoverItem?
                            
                            if let mainItemResults : Decoded<DiscoverItem> = decode(j) {
                                if let v = mainItemResults.value {
                                    mainItemParsed = v
                                }
                            }
                            
                            if let results : Decoded<[DiscoverItem]> = decode(jr) {
                                if let value = results.value {
                                    observer.on(.Next((mainItemParsed ?? discover, value)))
                                    observer.on(.Completed)
                                    return
                                }
                                if let err = results.error {
                                    observer.on(.Error(err))
                                }
                            }
                        }
                        
                    } catch let error as NSError {
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
                case .Failure(let error):
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                }
            })
            
            return AnonymousDisposable {
            }
        })
    }
    
}