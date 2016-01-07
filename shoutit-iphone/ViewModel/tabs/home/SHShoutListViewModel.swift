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
    private var discoverItems: [SHDiscoverItem] = []
    private let shApiShoutsService = SHApiShoutService()
    
    required init(viewController: SHShoutListViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        switch(viewController.type) {
        case .HOME:
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
        case .DISCOVER:
            break
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
        case .DISCOVER:
            return 5
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
        case .DISCOVER:
            switch indexPath.row {
            case 0:
                return getDiscoverFeedHeaderCell(indexPath)
            case 1:
                return getDiscoverFeedDiscoverListCell(indexPath)
            case 2:
                return getDiscoverShoutHeader(indexPath)
            case 3:
                return getShoutListCell(indexPath)
            case 4:
                return getDiscoverShowMoreShouts(indexPath)
            default:
                return getDiscoverListCell(indexPath)
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
        case .DISCOVER:
            switch indexPath.row {
            case 0:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 100)
            case 1:
                return CGSizeMake((UIScreen.mainScreen().bounds.width - 20) / 2, 200)
            case 2:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 50)
            case 3:
                return CGSizeMake((UIScreen.mainScreen().bounds.width - 20) / 2, 200)
            case 4:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 50)
            default:
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 50)
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
    
    private func getDiscoverFeedDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedDiscoverItemCell, forIndexPath: indexPath)
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
    
    //Extra discover cells
    private func getDiscoverFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedHeaderCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverShoutHeader(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShoutHeaderCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverShowMoreShouts(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShowMoreShoutsCell, forIndexPath: indexPath)
    }
    
}
