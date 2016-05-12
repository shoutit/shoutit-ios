//
//  DiscoverShoutsParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol DiscoverShoutsParentViewControllerFlowDelegate: class, ShoutDisplayable, SearchDisplayable {}

final class DiscoverShoutsParentViewController: UIViewController {
    
    // UI
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // view model
    var viewModel : DiscoverShoutsViewModel!
    
    // navigation
    weak var flowDelegate: DiscoverShoutsParentViewControllerFlowDelegate?
    
    // RX
    private let disposeBag = DisposeBag()
    
    var shoutsCollectionViewController : DiscoverShoutsCollectionViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let shoutsController = segue.destinationViewController as? DiscoverShoutsCollectionViewController {
            shoutsCollectionViewController = shoutsController
            shoutsCollectionViewController.viewModel = self.viewModel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        setupNavigationBar()
        
        self.titleLabel.text = self.viewModel.headerTitle()
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    private func setupRX() {
        self.changeLayoutButton.addTarget(shoutsCollectionViewController, action: #selector(DiscoverShoutsCollectionViewController.changeCollectionViewDisplayMode(_:)), forControlEvents: .TouchUpInside)
        
        shoutsCollectionViewController.selectedItem.asObservable().subscribeNext { [weak self] selectedShout in
            if let shout = selectedShout, let flowDelegate = self?.flowDelegate {
                flowDelegate.showShout(shout)
            }
        }.addDisposableTo(disposeBag)
        
        searchButton.rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.flowDelegate?.showSearchInContext(.DiscoverShouts(item: self.viewModel.discoverItem))
            }
            .addDisposableTo(disposeBag)
    }
}
