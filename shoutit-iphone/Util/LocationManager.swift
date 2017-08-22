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

let LocationManagerDidChangeAuthorizationStatus = "LocationManagerDidChangeAuthorizationStatus"

final class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let locationManager = CLLocationManager()
    fileprivate (set) var currentLocation = CLLocation() {
        didSet {
            updateUserCoordinates(currentLocation.coordinate)
        }
    }
    
    fileprivate override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func askForPermissions() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocationIfPermissionsGranted() {
        let autoUpdates = (UserDefaults.standard.object(forKey: Constants.Defaults.locationAutoUpdates) as? Bool) ?? false
        
        if autoUpdates && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func updateUserCoordinates(_ coordinates: CLLocationCoordinate2D) {
        
        guard let auto = UserDefaults.standard.object(forKey: Constants.Defaults.locationAutoUpdates) as? NSNumber else {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.first else {
            return
        }
        
        if CLLocationCoordinate2DIsValid(lastLocation.coordinate) {
            currentLocation = lastLocation
            stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if CLLocationCoordinate2DIsValid(newLocation.coordinate) {
            currentLocation = newLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: LocationManagerDidChangeAuthorizationStatus), object: manager)
    }
}
