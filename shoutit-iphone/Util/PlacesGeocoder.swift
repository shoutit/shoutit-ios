//
//  PlacesGeocoder.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import GooglePlaces
import RxSwift

public final class PlacesGeocoder: AnyObject {

    static let GooglePlacesApiKey = "AIzaSyBld5731YUMSNuLBO5Gu2L4Tsj-CrQZGIg"
    
    class func setup() {
        GooglePlaces.provideAPIKey(GooglePlacesApiKey)
    }
    
    
    public func rx_response(query: String!) -> Observable<([GooglePlaces.PlaceAutocompleteResponse.Prediction])> {
        return Observable.create { observer in
            if query.characters.count == 0 {
                observer.on(.Next([]))
            } else {
                
                GooglePlaces.placeAutocomplete(forInput: query, types: [.Geocode], completion: { (response, error) -> Void in
                    // Check Status Code
                    guard response?.status == GooglePlaces.StatusCode.OK else {
                        // Status Code is Not OK
                        observer.on(.Next([]))
                        
                        debugPrint(response?.errorMessage)
                        return
                    }
                    
                    // Use .predictions to access response details
                    debugPrint("first matched result: \(response?.predictions.first?.description)")
                    
                    if let predictions = response?.predictions {
                        observer.on(.Next(predictions))
                    } else {
                        observer.on(.Next([]))
                    }
                })
                
            }
      
            return AnonymousDisposable {
                
            }
        }
        
        
    }
    
    public func rx_details(placeId: String) -> Observable<GooglePlaces.PlaceDetailsResponse.Result?> {
        return Observable.create { observer in
            
            GooglePlaces.placeDetails(forPlaceID: placeId, completion: { (response, error) -> Void in
                guard response?.status == GooglePlaces.StatusCode.OK else {
                    // Status Code is Not OK
                    observer.on(.Next(nil))
                    
                    debugPrint(response?.errorMessage)
                    return
                }
                
                observer.on(.Next(response?.result))
            })
            
            return AnonymousDisposable {
                
            }
        }
        
    }
    
}

