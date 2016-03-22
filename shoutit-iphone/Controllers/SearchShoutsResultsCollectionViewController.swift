//
//  SearchShoutsResultsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class SearchShoutsResultsCollectionViewController: UICollectionViewController {
    
    // consts
    private let cellReuseIdentifier = "ShoutsCollectionViewCell"
    
    // view model
    var viewModel: SearchShoutsResultsViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        if let layout = collectionView?.collectionViewLayout as? SearchShoutsResultsCollectionViewLayout {
            layout.delegate = self
        }
        
        prepareReusables()
        setupRX()
    }
    
    // MARK: - Setup
    
    private func prepareReusables() {
        collectionView?.registerNib(UINib(nibName: ShoutsCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.registerNib(UINib(nibName: SearchShoutsResultsCollectionViewLayout.HeaderKind.Categories.rawValue, bundle: nil), forCellWithReuseIdentifier: SearchShoutsResultsCollectionViewLayout.HeaderKind.Categories.reuseIdentifier)
        collectionView?.registerNib(UINib(nibName: SearchShoutsResultsCollectionViewLayout.HeaderKind.Shouts.rawValue, bundle: nil), forCellWithReuseIdentifier: SearchShoutsResultsCollectionViewLayout.HeaderKind.Shouts.reuseIdentifier)
    }
    
    private func setupRX() {
        
        viewModel.shoutsSection.state
            .asDriver()
            .driveNext { (state) in
                
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchShoutsResultsCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
    }
}

// MARK: - UICollectionViewDelegate

extension SearchShoutsResultsCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - SearchShoutsResultsCollectionViewLayoutDelegate

extension SearchShoutsResultsCollectionViewController: SearchShoutsResultsCollectionViewLayoutDelegate {
    
    func sectionContentModeForSection(section: Int) -> SearchShoutsResultsCollectionSectionContentMode {
        
    }
}
