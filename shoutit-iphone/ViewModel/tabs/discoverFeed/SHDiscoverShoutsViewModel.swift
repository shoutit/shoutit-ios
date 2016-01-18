//
//  SHDiscoverShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutsViewModel: NSObject, ViewControllerModelProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let viewController: SHDiscoverShoutsViewController
    private var shApiShout = SHApiShoutService ()
    private var shouts: [SHShout] = []
    
    required init(viewController: SHDiscoverShoutsViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let discoverId = self.viewController.discoverId {
            self.fetchShoutsForLocation(discoverId)
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + shouts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch(indexPath.row) {
        case 0:
            return getDiscoverShoutsHeaderCell(indexPath)
        case 1...shouts.count:
            let cell = getShoutListCell(indexPath) as! SHDiscoverShoutCell
            cell.setUp(self.viewController, shout: self.shouts[indexPath.row - 1])
            return cell
        default:
            return getDiscoverShoutsHeaderCell(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSizeMake(UIScreen.mainScreen().bounds.width, 50)
        case 1...shouts.count:
            return CGSizeMake((UIScreen.mainScreen().bounds.width - 30) / 2, 172)
        default:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 44)
        }
    }
    
    // MARK - Private
    private func getDiscoverShoutsHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShoutsHeaderCell, forIndexPath: indexPath)
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
    
    private func updateShouts(shouts: SHShoutMeta) {
        self.shouts = shouts.results
        self.viewController.collectionView.reloadData()
    }
    
    private func getShoutListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverShoutCell, forIndexPath: indexPath) as! SHDiscoverShoutCell
    }

}
