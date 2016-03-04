//
//  ChangeLocationViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation
import GooglePlaces

class ChangeLocationViewModel: AnyObject {
    var searchTextObservable = PublishSubject<String>()
    let geocoder = PlacesGeocoder()
    var finalObservable : Observable<[GooglePlaces.PlaceAutocompleteResponse.Prediction]>?
    
    // View model
    required init() {
        finalObservable = searchTextObservable
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap { txt in
                return self.geocoder.rx_response(txt)
            }
    }
}
