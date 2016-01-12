//
//  SHShoutDiscoverListCellViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutDiscoverListCellViewModel: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private let cell: SHShoutDiscoverListCell
    private var discoverItems: [SHDiscoverItem] = []
    private var viewController: UIViewController?
    var type: ShoutListType = .HOME
    
    init(cell: SHShoutDiscoverListCell) {
        self.cell = cell
        super.init()
        getDiscoverItems()
    }
    
    func setUp(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    // MARK - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(type) {
        case .HOME:
            return discoverItems.count + 1
        case .DISCOVER:
            return discoverItems.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < discoverItems.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverItemCell, forIndexPath: indexPath) as! SHDiscoverItemCell
            cell.setUp(self.viewController, discoverItem: discoverItems[indexPath.row])
            addShadow(cell)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverSeeAllCell, forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch(type) {
        case .HOME:
            return CGSizeMake(90, 121)
        case .DISCOVER:
            return CGSizeMake(200, 240)
        }
    }
    
    // MARK - Private
    private func addShadow(cell: UICollectionViewCell) {
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1).CGColor
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowRadius = 1
        cell.layer.shadowOffset = CGSizeMake(0, 1)
    }
    
    private func getDiscoverItems() {
        SHApiDiscoverService().getDiscoverLocation(
            { (shDiscoverLocation) -> Void in
                self.gotDiscoverItems(shDiscoverLocation)
            }) { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.gotDiscoverItems(result)
                case .Failure(let error):
                    log.debug("\(error)")
                    // TODO
                }
        }
    }
    
    private func gotDiscoverItems(result: SHDiscoverLocation) {
        if result.results.count > 0, let discoverItemId = result.results[0].id {
            self.fetchDiscoverItems(discoverItemId)
        }
    }
    
    private func fetchDiscoverItems(id: String) {
        SHApiDiscoverService().getItemsFeedForLocation(id, cacheResponse: { (shDiscoverItem) -> Void in
            // Do Nothing here
            self.updateUI(shDiscoverItem)
            }, completionHandler: { (response) -> Void in
                self.cell.collectionView?.pullToRefreshView?.stopAnimating()
                switch(response.result) {
                case .Success(let result):
                    log.info("Success getting discover items")
                    self.updateUI(result)
                case .Failure(let error):
                    log.debug("\(error)")
                    // TODO
                }
            }
        )
    }
    
    // MARK - Private
    private func updateUI(discoverItem: SHDiscoverItem) {
        discoverItems = discoverItem.children
        self.cell.collectionView?.reloadData()
    }
}
