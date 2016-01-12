//
//  SHDiscoverFeedDiscoverItemCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/7/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedDiscoverItemCellViewModel: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private let cell: SHDiscoverFeedDiscoverItemCell
    private var discoverItems: [SHDiscoverItem] = []
    private var viewController: UIViewController?
    
    init(cell: SHDiscoverFeedDiscoverItemCell) {
        self.cell = cell
        super.init()
        getDiscoverItems()
    }
    
    func setUp(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    // MARK - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return discoverItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedCell, forIndexPath: indexPath) as! SHDiscoverFeedCell
        cell.setUp(self.viewController, discoverItem: discoverItems[indexPath.row])
        //addShadow(cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(200, 240)
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
