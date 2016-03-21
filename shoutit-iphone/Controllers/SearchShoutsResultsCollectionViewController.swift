//
//  SearchShoutsResultsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class SearchShoutsResultsCollectionViewController: UICollectionViewController {
    
    // view model
    var viewModel: SearchShoutsResultsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        
    }
}
