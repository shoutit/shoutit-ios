//
//  SHDiscoverViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverViewModel: NSObject, CollectionViewControllerModelProtocol, UICollectionViewDelegate, UICollectionViewDataSource {

    var viewController: SHDiscoverCollectionViewController
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private let shApiDiscoverService = SHApiDiscoverService()
    private let items = [SHDiscoverItem]()
    
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
    
    func discoverItems () {
        shApiDiscoverService.getDiscoverLocation({ (shDiscoverLocation) -> Void in
            //Do Nothing here
            }) { (response) -> Void in
                switch(response.result) {
                    case .Success(let result):
                    if let locationId = result.results[0].id {
                        self.shApiDiscoverService.getItemsFeedForLocation(locationId, cacheResponse: { (shDiscoverItem) -> Void in
                            // Do Nothing here
                            }, completionHandler: { (response) -> Void in
                                switch(response.result) {
                                case .Success(let result):
                                    log.info("Success")
                                case .Failure(let error):
                                    log.debug("\(error)")
                                }
                            }
                    )
                    }
                    case .Failure(let error):
                    log.debug("\(error)")
                
                }
        }
    }
    
    func setupNavigationBar () {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = self.viewController.title
        titleLabel.sizeToFit()
        let imageView = UIImageView(image: UIImage(named: "logoWhite.png"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.frame = CGRectMake(0, 0, 70, 44)
        let logo = UIBarButtonItem(customView: imageView)
        self.viewController.navigationItem.leftBarButtonItem = logo
        self.subTitleLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.origin.y + titleLabel.frame.size.height - 3, width: 100, height: 0))
   
        subTitleLabel.textAlignment = NSTextAlignment.Center
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        if let location = SHAddress.getUserOrDeviceLocation() {
        self.subTitleLabel.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
        self.subTitleLabel.sizeToFit()
        }
        self.subTitleLabel.center = CGPointMake(self.titleLabel.center.x, self.titleLabel.center.y)
    
        self.subTitleLabel?.sizeToFit()
        
        let twoLineTitleView = UIView(frame: self.titleLabel!.frame)
        twoLineTitleView.addSubview(self.titleLabel!)
        twoLineTitleView.addSubview(self.subTitleLabel!)
        self.subTitleLabel?.center = CGPointMake(self.titleLabel!.center.x, self.subTitleLabel!.center.y)
        self.viewController.navigationItem.titleView = twoLineTitleView
        self.subTitleLabel?.sizeToFit()
    
    }
    
    //Mark - CollectionViewDataSource

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHDiscoverCollectionViewCell, forIndexPath: indexPath) as? SHDiscoverCollectionViewCell {
            cell.textLabel.text = items[indexPath.row].title
            //        [cell.imageView setImageWithURL:[NSURL URLWithString:tag.image] placeholderImage:[UIImage imageNamed:@"image_placeholder"]  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            return cell
        }
        
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let navigation = SHNavigation()
        let detailViewController = navigation.viewControllerWithId("SHDiscoverDetailViewController")
        
      //  [detailViewController requestStreamForTag:self.tagModel.tags[indexPath.row] address:self.tagModel.currentLocation];
       // [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    
}
