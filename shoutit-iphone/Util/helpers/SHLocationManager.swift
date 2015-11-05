//
//  SHLocationManager.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 05/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import CoreLocation

class SHLocationManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = SHLocationManager()
    
    private let clLocationManager = CLLocationManager()
    private var currentLocation = CLLocation()
    private let geoCoder = CLGeocoder()
    private var country: String = ""
    private var isUpdating = false
    private var currentAddress: SHAddress?
    
    private override init() {
        super.init()
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdating() {
        self.clLocationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        self.clLocationManager.stopUpdatingLocation()
    }
    
    // MARK - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log.error("Error: Failed to Get Location")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.currentLocation = newLocation
        if self.currentAddress == nil {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.SharedUserDefaults.INIT_LOCATION)
//            [self addressOfCurrentLocationSuccess:^(SHLocationManager *manager, SHAddress *address)
//                {
//                self.currentAddress = address;
//                NSLog(@"Got first location.");
//                
//                } failure:^(SHLocationManager *manager, NSError *error, SHAddress *userAddress) {
//                NSLog(@"Error to get first location.");
//                }];
        }
//        let userLoc = CLLocation(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>))
    }
    
}
