//
//  DiscoverShoutsParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class DiscoverShoutsParentViewController: UIViewController {
    
    // UI
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // view model
    var viewModel : DiscoverShoutsViewModel!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // RX
    private let disposeBag = DisposeBag()
    
    var shoutsCollectionViewController : DiscoverShoutsCollectionViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let shoutsController = segue.destinationViewController as? DiscoverShoutsCollectionViewController {
            shoutsCollectionViewController = shoutsController
            shoutsCollectionViewController.viewModel = ShoutsCollectionViewModel(context: .DiscoverItemShouts(discoverItem: self.viewModel.discoverItem))
            shoutsCollectionViewController.flowDelegate = self.flowDelegate
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
        searchButton.rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.flowDelegate?.showSearchInContext(.DiscoverShouts(item: self.viewModel.discoverItem))
            }
            .addDisposableTo(disposeBag)
    }
}
