//
//  CLGeocoder+RX.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

extension CLGeocoder {
    public func rx_response(_ query: String!) -> Observable<([CLPlacemark])> {
        return Observable.create { observer in
            
            self.geocodeAddressString(query, completionHandler: { (placemarks, error) -> Void in
                if let plm = placemarks {
                    observer.on(.next(plm))
                }
                
                observer.on(.completed)
            })
            
            return Disposables.create {
                return self.cancelGeocode()
            }
        }
        
        
    }
}
