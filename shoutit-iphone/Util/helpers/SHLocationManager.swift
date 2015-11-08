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
    private var isUpdating = false
    private var shAddress: SHAddress?
    private var placemark: CLPlacemark?
    private let shApiMiscService = SHApiMiscService()
    private let shApiUserService = SHApiUserService()
    
    private let MIN_DISTANCE_TO_UPDATE_LOCATION: Double = 1000
    
    private override init() {
        super.init()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        self.clLocationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        self.clLocationManager.stopUpdatingLocation()
    }
    
    func isAddressAvailable() -> Bool {
        return self.shAddress != nil
    }
    
    func getAddress() -> SHAddress? {
        return shAddress
    }
    
    func getCurrentLocation() -> CLLocation? {
        return self.currentLocation
    }
    
    // MARK - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log.error("Error: Failed to Get Location")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.currentLocation = newLocation
        if self.shAddress == nil {
            self.shApiMiscService.geocodeLocation(newLocation.coordinate, cacheResponse: { (shAddress) -> Void in
                log.verbose("got cached address : \(shAddress.address)")
            }, completionHandler: { (response) -> Void in
                if response.result.isSuccess {
                    // Success
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.SharedUserDefaults.INIT_LOCATION)
                    self.shAddress = response.result.value
                    
                    log.verbose("got address from api : \(self.shAddress?.address)")
                } else {
                    // Failure
                    log.error("Error: Failed to Get location")
                }
            })
        }
        if let oauthToken = SHOauthToken.getFromCache() {
            if oauthToken.isSignedIn(), let lat = oauthToken.user?.location?.latitude, let lng = oauthToken.user?.location?.longitude, let userName = oauthToken.user?.username {
                let userLoc = CLLocation(latitude: Double(lat), longitude: Double(lng))
                if userLoc.distanceFromLocation(self.currentLocation) > MIN_DISTANCE_TO_UPDATE_LOCATION {
                    shApiUserService.updateLocation("\(userName)", latitude: lat, longitude: lng, completionHandler: { (response) -> Void in
                        if response.result.isSuccess {
                            oauthToken.updateUser(response.result.value)
                        }
                    })
                }
            }
            
        }
        
        
    }
   
}
