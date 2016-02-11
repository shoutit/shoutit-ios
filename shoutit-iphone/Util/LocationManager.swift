//
//  LocationManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    private let locationManager = CLLocationManager()
    private (set) var currentLocation = CLLocation() {
        didSet {
            updateUserCoordinates(currentLocation.coordinate)
        }
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = 5000 // 5000m to update location
        
        startMonitoringSignificantLocationChanges()
    }
    
    deinit {
        stopMonitoringSignificantLocationChanges()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func updateUserCoordinates(coordinates: CLLocationCoordinate2D) {
        guard let username = Account.sharedInstance.user?.username else {
            return
        }
        APILocationService.updateLocation(username, coordinates: coordinates) { (result) -> Void in
            
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.first else {
            return
        }
        
        if CLLocationCoordinate2DIsValid(lastLocation.coordinate) {
            currentLocation = lastLocation
            stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if CLLocationCoordinate2DIsValid(newLocation.coordinate) {
            currentLocation = newLocation
        }
    }
}