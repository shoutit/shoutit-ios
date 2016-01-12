//
//  SHDiscoverCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import SVPullToRefresh
import CoreLocation

class SHDiscoverCollectionViewController: BaseCollectionViewController, CLLocationManagerDelegate {

    private var viewModel: SHDiscoverViewModel?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup Delegates and data Source
        self.collectionView?.delegate = viewModel
        self.collectionView?.dataSource = viewModel
        self.CurrentLocationIdentifier()
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(5, 5, 5, 5)
        viewModel?.viewDidLoad()
    }
    
    func CurrentLocationIdentifier() {
        //---- For getting current gps location
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
        locationManager.stopUpdatingLocation()
        let geocoder = CLGeocoder()
        if let location = self.currentLocation {
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
                if(error != nil) {
                    log.error("Error fetching location \(error?.localizedDescription)")
                }
                if let locationPlacemarks = placemarks {
                    let placemark = locationPlacemarks[0]
                    NSUserDefaults.standardUserDefaults().setValue(placemark.locality, forKey: "MyLocality")
                    NSUserDefaults.standardUserDefaults().setValue(placemark.country, forKey: "MyCountry")
                    NSUserDefaults.standardUserDefaults().setValue(placemark.ISOcountryCode, forKey: "MyCountryCode")
                }
            }
        }
    }
    
    override func initializeViewModel() {
        viewModel = SHDiscoverViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setPullToRefresh()
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        viewModel?.destroy()
    }
    
    // MARK - Private
    private func setPullToRefresh() {
        self.collectionView?.addPullToRefreshWithActionHandler({ () -> Void in
            self.viewModel?.pullToRefresh()
        })
    }
    
}
