//
//  SHDiscoverFeedViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/6/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedViewModel: NSObject, ViewControllerModelProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let viewController: SHDiscoverFeedViewController
    private var discoverItems: [SHDiscoverItem] = []
    private var shouts: [SHShout] = []
    private var shApiShout = SHApiShoutService()
    private var oddNumberOfDiscoverItems: Int?
    
    required init(viewController: SHDiscoverFeedViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        getDiscoverItems()
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(discoverItems.count > 0 && shouts.count > 0) {
            return 3 + discoverItems.count + shouts.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch(indexPath.row) {
        case 0:
            let cell = getDiscoverFeedHeaderCell(indexPath)
            addShadow(cell)
            return cell
        case 1...discoverItems.count:
            let cell = getDiscoverListCell(indexPath) as! SHDiscoverFeedCell
            cell.setUp(self.viewController, discoverItem: self.discoverItems[indexPath.row - 1])
            return cell
        case discoverItems.count + 1:
            return getDiscoverShoutHeaderCell(indexPath)
        case (discoverItems.count + 2)...(discoverItems.count + 5):
            return getShoutListCell(indexPath)
        default:
            let cell = getSeeAllShoutsCell(indexPath)
            addBorder(cell)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 132)
        case 1...discoverItems.count:
            return CGSizeMake((UIScreen.mainScreen().bounds.width - 30) / 2, 165)
        case discoverItems.count + 1:
            return CGSizeMake(UIScreen.mainScreen().bounds.width, 44)
        case (discoverItems.count + 2)...(discoverItems.count + 5):
            return CGSizeMake((UIScreen.mainScreen().bounds.width - 30) / 2, 172)
        default:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 44)
        }
    }
    
    // MARK - Private
    private func getDiscoverFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedHeaderCell, forIndexPath: indexPath)
    }

    private func getDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverShoutHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShoutHeaderCell, forIndexPath: indexPath)
    }

    private func getShoutListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier("SHDiscoverShoutsCell", forIndexPath: indexPath) as! SHDiscoverShoutsCell
        cell.setUp(self.viewController, shout: self.shouts[indexPath.row - (discoverItems.count + 2)])
        return cell
    }
    
    private func getSeeAllShoutsCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShowMoreShoutsCell, forIndexPath: indexPath)
    }
    
    private func addBorder(cell: UICollectionViewCell) {
        cell.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_BORDER_DISCOVER)?.CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
    }
    
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
            self.fetchShoutsForLocation(id)
            self.updateUI(shDiscoverItem)
            }, completionHandler: { (response) -> Void in
               // self.viewController.collectionView?.pullToRefreshView?.stopAnimating()
                switch(response.result) {
                case .Success(let result):
                    self.fetchShoutsForLocation(id)
                    log.info("Success getting discover items")
                    self.updateUI(result)
                case .Failure(let error):
                    log.debug("\(error)")
                    // TODO
                }
            }
        )
    }
    
    private func fetchShoutsForLocation(discoverId: String) {
        shApiShout.discoverId = discoverId
        shApiShout.loadShoutStreamForLocation(nil, page: 1, type: ShoutType.Offer, query: nil, cacheResponse: { (shShoutMeta) -> Void in
            self.updateShouts(shShoutMeta)
            }) { (response) -> Void in
                self.viewController.collectionView?.pullToRefreshView?.stopAnimating()
                switch(response.result) {
                case .Success(let result):
                    log.info("Success getting shouts")
                    self.updateShouts(result)
                case .Failure(let error):
                    log.debug("\(error)")
                    // TODO
                }
        }
    }
    
    private func updateUI(discoverItem: SHDiscoverItem) {
        self.discoverItems = discoverItem.children
    }
    
    private func updateShouts(shouts: SHShoutMeta) {
        self.shouts = shouts.results
        self.viewController.collectionView.reloadData()
    }

}
