//
//  SHDiscoverViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverViewModel: NSObject, CollectionViewControllerModelProtocol {

    var viewController: SHDiscoverCollectionViewController
    private var titleLabel: UILabel?
    private var subTitleLabel: UILabel?
    private let shApiDiscoverService = SHApiDiscoverService()
    
    required init(viewController: SHDiscoverCollectionViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
}
