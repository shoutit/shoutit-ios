//
//  ChangeLocationTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import GooglePlaces
import CoreLocation

class ChangeLocationTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var currentLocationLabel : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    var finishedBlock: ((Bool, Address?) -> Void)?
    
    private let disposeBag = DisposeBag()
    private let viewModel = ChangeLocationViewModel()
    private let cellIdentifier = "ChangeLocationCellIdentifier"
    
    var currentLocationText : String! {
        didSet {
            loading = false
            currentLocationLabel.text = "\(NSLocalizedString("Your current location:", comment: "")) \(currentLocationText)"
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
        setupObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialState()
    }
    
    @IBAction func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadInitialState() {
        currentLocationText = Account.sharedInstance.locationString()
    }
    
    func setupObservers() {
        _ = searchBar.rx_text.bindTo(viewModel.searchTextObservable).addDisposableTo(disposeBag)

        viewModel.finalObservable?
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellIdentifier, cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.description!)"
            }.addDisposableTo(disposeBag)
        
        
        tableView.rx_modelSelected(GooglePlaces.PlaceAutocompleteResponse.Prediction.self)
            .asDriver()
            .driveNext { selectedLocation in
         
                self.loading = true
                
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
        
        APILocationService.updateLocationForUser(username, withParams: params).subscribeNext {[weak self] (_) in
            if let finish = self?.finishedBlock {
                self?.searchBar.text = ""
                finish(true, address)
            }
        }.addDisposableTo(disposeBag)
    }
}
