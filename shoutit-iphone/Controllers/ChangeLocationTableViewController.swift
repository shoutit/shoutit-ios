//
//  ChangeLocationTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 10/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import FTGooglePlacesAPI

class ChangeLocationTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var currentLocationLabel : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var searchBar : UISearchBar!
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialState()
        setupObservers()
    }
    
    func loadInitialState() {
        currentLocationText = Account.locationString()
    }
    
    func setupObservers() {
        _ = searchBar.rx_text.bindTo(viewModel.searchTextObservable).addDisposableTo(disposeBag)

        viewModel.finalObservable?
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellIdentifier, cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.name!)"
            }.addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(FTGooglePlacesAPISearchResultItem.self)
            .asDriver()
            .driveNext { selectedLocation in
                let coordinates : CLLocationCoordinate2D = selectedLocation.location.coordinate
                
                guard let username = Account.sharedInstance.user?.username else {
                    return
                }
                
                APILocationService.updateLocation(username, coordinates: coordinates) { (result) -> Void in
                    
                }
                
            }
            .addDisposableTo(disposeBag)
        
    }
    
}
