//
//  DiscoverShoutsParentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class DiscoverShoutsParentViewController: UIViewController {
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel : DiscoverShoutsViewModel!
    
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
    
    func setupNavigationBar() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    func setupRX() {
        self.changeLayoutButton.addTarget(shoutsCollectionViewController, action: "changeCollectionViewDisplayMode:", forControlEvents: .TouchUpInside)
        
        shoutsCollectionViewController.selectedItem.asObservable().subscribeNext { [weak self] selectedShout in
            if let _ = selectedShout {
                self?.performSegueWithIdentifier("showSingleShout", sender: nil)
            }
        }.addDisposableTo(disposeBag)
    }
}
