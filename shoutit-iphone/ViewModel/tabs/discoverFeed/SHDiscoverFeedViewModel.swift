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
    private var numberOfDiscoverItems = 0
    private var isDiscoverCountOdd = false
    
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
            return 3 + numberOfDiscoverItems + shouts.count
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
        case 1...numberOfDiscoverItems:
            if(indexPath.row < numberOfDiscoverItems && isDiscoverCountOdd) {
                let cell = getDiscoverListCell(indexPath) as! SHDiscoverFeedCell
                cell.setUp(self.viewController, discoverItem: self.discoverItems[indexPath.row - 1])
                return cell
            } else {
                let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHExtraDiscoverCell, forIndexPath: indexPath)
                return cell
            }
        case numberOfDiscoverItems + 1:
            return getDiscoverShoutHeaderCell(indexPath)
        case (numberOfDiscoverItems + 2)...(numberOfDiscoverItems + 5):
            let cell = getShoutListCell(indexPath) as! SHDiscoverShoutCell
            cell.setUp(self.viewController, shout: self.shouts[indexPath.row - (numberOfDiscoverItems + 2)])
            return cell
        default:
            let cell = getSeeAllShoutsCell(indexPath) as! SHDiscoverShowMoreShoutsCell
            cell.setup(self.viewController)
            addBorder(cell)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 132)
        case 1...numberOfDiscoverItems:
            return CGSizeMake((UIScreen.mainScreen().bounds.width - 30) / 2, 165)
        case numberOfDiscoverItems + 1:
            return CGSizeMake(UIScreen.mainScreen().bounds.width, 44)
        case (numberOfDiscoverItems + 2)...(numberOfDiscoverItems + 5):
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
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShoutCell, forIndexPath: indexPath) as! SHDiscoverShoutCell
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
            self.viewController.discoverId = discoverItemId
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
        shApiShout.pageSize = 4
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
        if(self.discoverItems.count % 2 == 0) {
            self.numberOfDiscoverItems = self.discoverItems.count
        } else {
            self.numberOfDiscoverItems = self.discoverItems.count + 1
            self.isDiscoverCountOdd = true
        }
    }
    
    private func updateShouts(shouts: SHShoutMeta) {
        self.shouts = shouts.results
        self.viewController.collectionView.reloadData()
    }

}
