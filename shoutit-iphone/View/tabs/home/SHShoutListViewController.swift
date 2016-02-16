//
//  SHHomeViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

enum ShoutListType {
    case HOME
}

enum ShoutViewType {
    case GRID
    case LIST
}

class SHShoutListViewController: UIViewController {
    /*
    private var shouts: [SHShout] = []
    private var discoverItems: [SHDiscoverItem] = []
    private let shApiShoutsService = SHApiShoutService()
    
    var type: ShoutListType = .HOME
    var viewType: ShoutViewType = .GRID {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func updateUI() {
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3 + shouts.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 41)
        case 1:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 121)
        case 2:
            return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 41)
        default:
            switch self.viewType {
            case .GRID:
                let imageWidth = (UIScreen.mainScreen().bounds.width - 30) / 2
                return CGSizeMake(imageWidth, imageWidth + 39)
            case .LIST:
                return CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 110)
            }
        }
    }
    
    // MARK - Private
    private func getDiscoverTitleCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverTitleCell, forIndexPath: indexPath)
    }
    
    private func getDiscoverListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutDiscoverListCell, forIndexPath: indexPath)
    }
    
    private func getMyFeedHeaderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutMyFeedHeaderCell, forIndexPath: indexPath) as! SHShoutMyFeedHeaderCell
        cell.setUp(self)
        return cell
    }
    
//    private func getShoutListCell(indexPath: NSIndexPath) -> UICollectionViewCell {
//        switch(self.viewType) {
//        case .GRID:
//            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutItemGridCell, forIndexPath: indexPath) as! SHShoutItemCell
//            cell.setUp(self, shout: self.shouts[indexPath.row - 3])
//            return cell
//        case .LIST:
//            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.ShoutItemListCell, forIndexPath: indexPath) as! SHShoutItemCell
//            cell.setUp(self, shout: self.shouts[indexPath.row - 3])
//            return cell
//        }
//    }
*/
}
