//
//  LocationManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    private let locationManager = CLLocationManager()
    private (set) var currentLocation = CLLocation()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5000 // 5000m to update location
    }
    
    func startUpdatingLocation() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        currentLocation = newLocation
    }
}