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
    private var shouts: [SHShout] = []
    private let shApiShoutsService = SHApiShoutService()
    
    required init(viewController: SHShoutListViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        shApiShoutsService.loadHomeShouts(1, cacheResponse: { (shShoutMeta) -> Void in
            self.shouts = shShoutMeta.results
            self.updateUI()
            }) { (response) -> Void in
                switch response.result {
                case .Success(let shShoutMeta):
                    self.shouts = shShoutMeta.results
                    self.updateUI()
                case .Failure(let error):
                    log.error("Error fetching shouts \(error.localizedDescription)")
                }
        }
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
    
    func updateUI() {
        self.viewController.collectionView.reloadData()
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
                return getShoutListCell(indexPath)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch (viewController.type) {
        case .HOME:
            switch indexPath.row {
            case 0:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 41)
            case 1:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 121)
            case 2:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 41)
            default:
                switch self.viewController.viewType {
                case .GRID:
                    let imageWidth = (UIScreen.mainScreen().bounds.width - 30) / 2
                    return CGSizeMake(imageWidth, imageWidth + 39)
                case .LIST:
                    return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 110)
                }
            }
        }
    }
    
    // MARK - Private
    private func getDiscoverTitleCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverTitleCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverListCell, forIndexPath: indexPath)
    }
    
    private func getMyFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutMyFeedHeaderCell, forIndexPath: indexPath) as! SHShoutMyFeedHeaderCell
        cell.setUp(self.viewController)
        return cell
    }
    
    private func getShoutListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        switch(self.viewController.viewType) {
        case .GRID:
            let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutItemGridCell, forIndexPath: indexPath) as! SHShoutItemCell
            cell.setUp(self.viewController, shout: self.shouts[indexPath.row - 3])
            addBorder(cell)
            return cell
        case .LIST:
            let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutItemListCell, forIndexPath: indexPath) as! SHShoutItemCell
            cell.setUp(self.viewController, shout: self.shouts[indexPath.row - 3])
            addBorder(cell)
            return cell
        }
    }
    
    private func addBorder(cell: UICollectionViewCell) {
        cell.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_BORDER_DISCOVER)?.CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
    }
}
