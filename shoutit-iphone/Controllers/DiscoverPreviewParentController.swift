//
//  DiscoverPreviewParentController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class DiscoverPreviewParentController: UIViewController {
    
    var discoverController : DiscoverPreviewCollectionViewController?
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var titleLabel : UILabel?
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let discover = segue.destinationViewController as? DiscoverPreviewCollectionViewController {
            discoverController = discover
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discoverController?
            .viewModel
            .mainItemObservable
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (item) -> Void in
                if let discover = item {
                    self?.titleLabel?.text = discover.title
                }
            }
            .addDisposableTo(disposeBag)
    }
}   
