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
    
    required init(viewController: SHDiscoverFeedViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
       // getDiscoverItems()
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return getDiscoverFeedHeaderCell(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSizeMake(UIScreen.mainScreen().bounds.width, 132)
        default:
            return CGSizeMake(172, 172)
        }
    }
    
    // MARK - Private
    private func getDiscoverFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverFeedHeaderCell, forIndexPath: indexPath)
    }
//
//    private func getDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
//        return self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverListCell, forIndexPath: indexPath)
//    }
//    
//    private func getShoutListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = self.viewController.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutItemGridCell, forIndexPath: indexPath) as! SHShoutItemCell
//        cell.setUp(self.viewController, shout: self.shouts[indexPath.row - 3])
//        addBorder(cell)
//        return cell
//        
//    }
    
    private func addBorder(cell: UICollectionViewCell) {
        cell.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_BORDER_DISCOVER)?.CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
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
                self.viewController.collectionView?.pullToRefreshView?.stopAnimating()
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
    
    private func updateUI(discoverItem: SHDiscoverItem) {
        discoverItems = discoverItem.children
        self.viewController.collectionView?.reloadData()
    }
    

}
