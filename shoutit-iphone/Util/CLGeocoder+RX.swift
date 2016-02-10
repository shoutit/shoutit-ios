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
    public func rx_response(query: String!) -> Observable<([CLPlacemark])> {
        return Observable.create { observer in
            
            self.geocodeAddressString(query, completionHandler: { (placemarks, error) -> Void in
                if let plm = placemarks {
                    observer.on(.Next(plm))
                }
                
                observer.on(.Completed)
            })
            
            return AnonymousDisposable {
                return self.cancelGeocode()
            }
        }
        
        
    }
}
