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
    
    var finishedBlock: ((Bool) -> Void)?
    
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
    
    func loadInitialState() {
        currentLocationText = Account.sharedInstance.locationString()
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
                
                self.loading = true
                
                APILocationService.updateLocation(username, coordinates: coordinates) { (result) -> Void in
                    if let finish = self.finishedBlock {
                        self.searchBar.text = ""
                        finish(true)
                    }
                }
                
            }
            .addDisposableTo(disposeBag)

        Account.sharedInstance.userSubject.subscribeNext { (user: User?) in
            self.loadInitialState()
        }.addDisposableTo(disposeBag)
    }
    
}
