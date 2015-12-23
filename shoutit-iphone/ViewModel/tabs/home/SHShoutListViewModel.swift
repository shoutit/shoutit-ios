//
//  SHHomeViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutListViewModel: NSObject, ViewControllerModelProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let viewController: SHShoutListViewController
    private let shouts: [SHShout] = []
    
    required init(viewController: SHShoutListViewController) {
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
    
    // MARK - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (viewController.type) {
        case .HOME:
            return 3 + shouts.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch (viewController.type) {
        case .HOME:
            switch indexPath.row {
            case 0:
                return getDiscoverTitleCell(indexPath)
            case 1:
                return getDiscoverListCell(indexPath)
            case 2:
                return getMyFeedHeaderCell(indexPath)
            default:
                break
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch (viewController.type) {
        case .HOME:
            switch indexPath.row {
            case 0:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 41)
            case 1:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 119)
            case 2:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 41)
            default:
                break
            }
        }
        return CGSizeMake(0,0)
    }
    
    // MARK - Private
    private func getDiscoverTitleCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverTitleCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverListCell, forIndexPath: indexPath)
    }
    
    private func getMyFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutMyFeedHeaderCell, forIndexPath: indexPath)
    }
}
