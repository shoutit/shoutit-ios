//
//  PlacesGeocoder.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

public final class PlacesGeocoder: AnyObject {

    static let GooglePlacesApiKey = "AIzaSyBld5731YUMSNuLBO5Gu2L4Tsj-CrQZGIg"
    
    class func setup() {
        GooglePlaces.provideAPIKey(GooglePlacesApiKey)
    }
    
    
    public func rx_response(_ query: String!) -> Observable<([GooglePlaces.PlaceAutocompleteResponse.Prediction])> {
        return Observable.create { observer in
            if query.characters.count == 0 {
                observer.on(.next([]))
            } else {
                
                GooglePlaces.placeAutocomplete(forInput: query, types: [.Geocode], completion: { (response, error) -> Void in
                    // Check Status Code
                    guard response?.status == GooglePlaces.StatusCode.OK else {
                        // Status Code is Not OK
                        observer.on(.next([]))
                        
                        debugPrint(response?.errorMessage)
                        return
                    }
                    
                    // Use .predictions to access response details
                    debugPrint("first matched result: \(response?.predictions.first?.description)")
                    
                    if let predictions = response?.predictions {
                        observer.on(.next(predictions))
                    } else {
                        observer.on(.next([]))
                    }
                })
                
            }
      
            return AnonymousDisposable {
                
            }
        }
        
        
    }
    
    public func rx_details(_ placeId: String) -> Observable<GooglePlaces.PlaceDetailsResponse.Result?> {
        return Observable.create { observer in
            
            GooglePlaces.placeDetails(forPlaceID: placeId, completion: { (response, error) -> Void in
                guard response?.status == GooglePlaces.StatusCode.OK else {
                    // Status Code is Not OK
                    observer.on(.next(nil))
                    
                    debugPrint(response?.errorMessage)
                    return
                }
                
                observer.on(.next(response?.result))
            })
            
            return AnonymousDisposable {
                
            }
        }
        
    }
    
}

