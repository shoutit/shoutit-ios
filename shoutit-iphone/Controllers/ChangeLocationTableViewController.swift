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
    
    private let disposeBag = DisposeBag()
    private let viewModel = ChangeLocationViewModel()
    private let cellIdentifier = "ChangeLocationCellIdentifier"
    
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
            NSUserDefaults.standardUserDefaults().setObject(autoUpdates, forKey: Constants.Defaults.locationAutoUpdates)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if autoUpdates {
                LocationManager.sharedInstance.askForPermissions()
            } else {
                LocationManager.sharedInstance.stopUpdatingLocation()
            }
        }
    }
    
    var loading : Bool = true {
        didSet {
            currentLocationLabel.hidden = loading
            activityIndicator.hidden = !loading
            if loading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auto = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Defaults.locationAutoUpdates) as? Bool {
            autoUpdates = auto
        }
        
        if shouldShowAutoUpdates {
            showAutoUpdatesButton()
        }
        
        setupObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    func showAutoUpdatesButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Auto", comment: "Automatically get user location"), style: .Plain, target: self, action: #selector(toggleAutoUpdates))
    }
    
    func toggleAutoUpdates() {
        let alert = UIAlertController(title: NSLocalizedString("Automatically Location Updates", comment: "Change Location Screen option"), message: "", preferredStyle: .ActionSheet)
        
        if self.autoUpdates {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", comment: "Turn off auto location update"), style: .Default, handler: { (action) in
                self.autoUpdates = false
            }))
        } else {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Turn On", comment: "Turn on auto location update"), style: .Default, handler: { (action) in
                self.autoUpdates = true
            }))
        }
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: { (action) in }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func setAutoLocationUpdates(autoUpdates: Bool) {
        self.autoUpdates = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialState()
    }
    
    @IBAction override func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
        _ = searchBar.rx_text.bindTo(viewModel.searchTextObservable).addDisposableTo(disposeBag)

        viewModel.finalObservable?
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellIdentifier, cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.description!)"
            }.addDisposableTo(disposeBag)
        
        
        tableView.rx_modelSelected(GooglePlaces.PlaceAutocompleteResponse.Prediction.self)
            .asDriver()
            .driveNext {[weak self] selectedLocation in
                
                guard let `self` = self else { return }
                
                self.showProgressHUD()
                self.loading = true
                self.autoUpdates = false
                
                guard let place = selectedLocation.place else { return }
                guard case .PlaceID(let plId) = place else { return }
                self.viewModel.geocoder
                    .rx_details(plId)
                    .filter{$0?.geometryLocation != nil}
                    .flatMap {(place) -> Observable<Address> in
                        let params = GeocodeParams(latitude: place!.geometryLocation!.latitude, longitude: place!.geometryLocation!.longitude)
                        return APIMiscService.geocode(params)
                    }
                    .subscribeNext{ [weak self] (address) -> Void in
                        self?.finishWithAddress(address)
                    }
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)

        Account.sharedInstance.userSubject.subscribeNext { (_) in
            self.loadInitialState()
        }.addDisposableTo(disposeBag)
    }
    
    func finishWithAddress(address: Address) {
        
        guard let username = Account.sharedInstance.user?.username else {
            return
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: address.latitude ?? 0, longitude: address.longitude ?? 0)
        let params = CoordinateParams(coordinates: coordinates)
        
        if case .Some(.Page(_,_)) = Account.sharedInstance.loginState {
            APILocationService.updateLocationForPage(username, withParams: params).subscribeNext {[weak self] (_) in
                if let finish = self?.finishedBlock {
                    self?.searchBar.text = ""
                    self?.hideProgressHUD()
                    finish(true, address)
                }
                }.addDisposableTo(disposeBag)
            
            return
        }
        
        APILocationService.updateLocationForUser(username, withParams: params).subscribeNext {[weak self] (_) in
            if let finish = self?.finishedBlock {
                self?.searchBar.text = ""
                self?.hideProgressHUD()
                finish(true, address)
            }
        }.addDisposableTo(disposeBag)
    }
}
