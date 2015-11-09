//
//  SHDiscoverViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher

class SHDiscoverViewModel: NSObject, CollectionViewControllerModelProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    let viewController: SHDiscoverCollectionViewController
    private let shApiDiscoverService = SHApiDiscoverService()
    private var items: [SHDiscoverItem] = []
    
    required init(viewController: SHDiscoverCollectionViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        discoverItems()
        setupNavigationBar()
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
    
    //Mark - CollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverCollectionViewCell, forIndexPath: indexPath) as! SHDiscoverCollectionViewCell
        cell.setUp(items[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return (collectionViewLayout as! SHDiscoverFlowLayout).sizeCellForRowAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO open shouts
    }
    
    // MARK - Private
    private func updateUI(discoverItem: SHDiscoverItem) {
        // TODO Update UI Here
        items = discoverItem.children
        self.viewController.collectionView?.reloadData()
    }
    
    private func discoverItems() {
        shApiDiscoverService.getDiscoverLocation(
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
        self.shApiDiscoverService.getItemsFeedForLocation(id, cacheResponse: { (shDiscoverItem) -> Void in
                // Do Nothing here
                self.updateUI(shDiscoverItem)
            }, completionHandler: { (response) -> Void in
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
    
    private func setupNavigationBar() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = self.viewController.title
        titleLabel.sizeToFit()
        let imageView = UIImageView(image: UIImage(named: "logoWhite"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.frame = CGRectMake(0, 0, 70, 44)
        let logo = UIBarButtonItem(customView: imageView)
        self.viewController.navigationItem.leftBarButtonItem = logo
        
        let subTitleLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.origin.y + titleLabel.frame.size.height - 3, width: 100, height: 0))
        subTitleLabel.textAlignment = NSTextAlignment.Center
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        if let location = SHAddress.getUserOrDeviceLocation() {
            subTitleLabel.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
            subTitleLabel.sizeToFit()
        }
        subTitleLabel.center = CGPointMake(titleLabel.center.x, titleLabel.center.y)
        subTitleLabel.sizeToFit()
        
        let twoLineTitleView = UIView(frame: titleLabel.frame)
        twoLineTitleView.addSubview(titleLabel)
        twoLineTitleView.addSubview(subTitleLabel)
        subTitleLabel.center = CGPointMake(titleLabel.center.x, subTitleLabel.center.y)
        self.viewController.navigationItem.titleView = twoLineTitleView
        subTitleLabel.sizeToFit()
    }
    
}
