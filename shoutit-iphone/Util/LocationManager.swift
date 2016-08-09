//
//  LocationManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import ShoutitKit

final class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    private let disposeBag = DisposeBag()
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
    }
    
    func askForPermissions() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocationIfPermissionsGranted() {
        let autoUpdates = (NSUserDefaults.standardUserDefaults().objectForKey(Constants.Defaults.locationAutoUpdates) as? Bool) ?? false
        
        if autoUpdates && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func updateUserCoordinates(coordinates: CLLocationCoordinate2D) {
        
        guard let auto = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Defaults.locationAutoUpdates) as? NSNumber else {
            return
        }

        if auto.boolValue == false {
            return
        }
        
        guard let username = Account.sharedInstance.user?.username else {
            return
        }
        
        let coordinateParams = CoordinateParams(coordinates: coordinates)
        
        APILocationService.updateLocationForUser(username, withParams: coordinateParams).subscribeNext{(_) in}.addDisposableTo(disposeBag)
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