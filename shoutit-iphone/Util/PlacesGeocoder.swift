//
//  PlacesGeocoder.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import FTGooglePlacesAPI
import RxSwift

public final class PlacesGeocoder: AnyObject {

    static let GooglePlacesApiKey = "AIzaSyBld5731YUMSNuLBO5Gu2L4Tsj-CrQZGIg"
    
    class func setup() {
        FTGooglePlacesAPIService.provideAPIKey(GooglePlacesApiKey)
    }
    
    
    public func rx_response(query: String!) -> Observable<([AnyObject])> {
        return Observable.create { observer in
            if query.characters.count == 0 {
                observer.on(.Next([]))
            } else {
                let request = FTGooglePlacesAPITextSearchRequest(query: query)
                
                FTGooglePlacesAPIService.executeSearchRequest(request, withCompletionHandler: { (response, error) -> Void in
                    if let results =  response.results {
                        observer.on(.Next(results))
                    } else {
                        observer.on(.Next([]))
                    }
                    
                    observer.on(.Completed)
                })
            }
      
            return AnonymousDisposable {
                
            }
        }
        
        
    }
    
}

