//
//  ChangeLocationTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation
import ShoutitKit

class ChangeLocationTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var currentLocationLabel : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    var finishedBlock: ((Bool, Address?) -> Void)?
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel = ChangeLocationViewModel()
    fileprivate let cellIdentifier = "ChangeLocationCellIdentifier"
    
    var shouldShowAutoUpdates : Bool = true
    
    var currentLocationText : String! {
        didSet {
            loading = false
            currentLocationLabel.text = "\(NSLocalizedString("Current location:", comment: "Current Location Title in Change Location Screen")) \(currentLocationText)"
        }
    }
    
    var autoUpdates : Bool = false {
        didSet {
            loadInitialState()
            UserDefaults.standard.set(autoUpdates, forKey: Constants.Defaults.locationAutoUpdates)
            UserDefaults.standard.synchronize()
        }
    }
    
    var loading : Bool = true {
        didSet {
            currentLocationLabel.isHidden = loading
            activityIndicator.isHidden = !loading
            if loading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auto = UserDefaults.standard.object(forKey: Constants.Defaults.locationAutoUpdates) as? Bool {
            autoUpdates = auto
        }
        
        if shouldShowAutoUpdates {
            showAutoUpdatesButton()
        }
        
        setupObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(authorizationStatusDidChange), name: NSNotification.Name(rawValue: LocationManagerDidChangeAuthorizationStatus), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LocationManagerDidChangeAuthorizationStatus), object: nil)
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    func showAutoUpdatesButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Auto", comment: "Automatically get user location"), style: .plain, target: self, action: #selector(toggleAutoUpdates))
    }
    
    func toggleAutoUpdates() {
        let alert = UIAlertController(title: NSLocalizedString("Automatically Location Updates", comment: "Change Location Screen option"), message: "", preferredStyle: .actionSheet)
        
        if self.autoUpdates {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", comment: "Turn off auto location update"), style: .default, handler: { (action) in
                self.autoUpdates = false
            }))
        } else {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Turn On", comment: "Turn on auto location update"), style: .default, handler: { (action) in
                
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    self.autoUpdates = true
                } else if CLLocationManager.authorizationStatus() == .denied {
                    // go to settings
                    
                    let alertController = UIAlertController(title: NSLocalizedString("Shoutit is not authorized to use your location. Please go to Settings and change location permissions.", comment: ""), message: nil, preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Go to settings button"), style: .default) { (alertAction) in
                        
                        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(appSettings)
                        }
                    }
                    alertController.addAction(settingsAction)
                    
                    let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.navigationController?.present(alertController, animated: true, completion: nil)
                    
                } else {
                    LocationManager.sharedInstance.askForPermissions()
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: { (action) in }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func authorizationStatusDidChange(_ notification: Foundation.Notification) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.autoUpdates = false
        } else {
            self.autoUpdates = true
            LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
        }
    }
    
    fileprivate func setAutoLocationUpdates(_ autoUpdates: Bool) {
        self.autoUpdates = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialState()
    }
    
    @IBAction override func dismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func loadInitialState() {
        if shouldShowAutoUpdates && autoUpdates {
            loading = false
            currentLocationLabel.text = NSLocalizedString("Your location will be updated automatically", comment: "change location header title for auto location")
        } else {
            currentLocationText = Account.sharedInstance.locationString()
        }
    }
    
    func setupObservers() {
        
        setupKeyboardOffsetNotifcationObserver()
        // ref
//        _ = searchBar.rx.text.bind(to: viewModel.searchTextObservable).addDisposableTo(disposeBag)

        // ref
//        viewModel.finalObservable?
//            .bind(to: tableView.rx.itemsWithCellIdentifier(cellIdentifier, cellType: UITableViewCell.self)) { (row, element, cell) in
//                cell.textLabel?.text = "\(element.description!)"
//            }.addDisposableTo(disposeBag)
        
        
        tableView.rx.modelSelected(GooglePlaces.PlaceAutocompleteResponse.Prediction.self)
            .asDriver()
            .drive(onNext: { [weak self] selectedLocation in
                
                guard let `self` = self else { return }
                
                self.showProgressHUD()
                self.loading = true
                self.autoUpdates = false
                
                guard let place = selectedLocation.place else { return }
                guard case .placeID(let plId) = place else { return }
                self.viewModel.geocoder
                    .rx_details(plId)
                    .filter{$0?.geometryLocation != nil}
                    .flatMap {(place) -> Observable<Address> in
                        let params = GeocodeParams(latitude: place!.geometryLocation!.latitude, longitude: place!.geometryLocation!.longitude)
                        return APIMiscService.geocode(params)
                    }
                    .subscribe(onNext: { [weak self] (address) -> Void in
                        self?.finishWithAddress(address)
                    })
                    .addDisposableTo(self.disposeBag)
            })
            .addDisposableTo(disposeBag)

        Account.sharedInstance.userSubject.subscribe(onNext: { (_) in
            self.loadInitialState()
        }).addDisposableTo(disposeBag)
    }
    
    func finishWithAddress(_ address: Address) {
        
        guard let username = Account.sharedInstance.user?.username else {
            return
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: address.latitude ?? 0, longitude: address.longitude ?? 0)
        let params = CoordinateParams(coordinates: coordinates)
        
        if case .some(.page(_,_)) = Account.sharedInstance.loginState {
            APILocationService.updateLocationForPage(username, withParams: params).subscribe(onNext: {[weak self] (_) in
                if let finish = self?.finishedBlock {
                    self?.searchBar.text = ""
                    self?.hideProgressHUD()
                    finish(true, address)
                }
                }).addDisposableTo(disposeBag)
            
            return
        }
        
        APILocationService.updateLocationForUser(username, withParams: params).subscribe(onNext: {[weak self] (_) in
            if let finish = self?.finishedBlock {
                self?.searchBar.text = ""
                self?.hideProgressHUD()
                finish(true, address)
            }
        }).addDisposableTo(disposeBag)
    }
}
