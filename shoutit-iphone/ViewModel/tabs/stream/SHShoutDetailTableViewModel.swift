//
//  SHShoutDetailTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 22/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHShoutDetailTableViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, YTPlayerViewDelegate {

    private let viewController: SHShoutDetailTableViewController
    private let shApiShout = SHApiShoutService()
    private var shoutDetail: SHShout?
    
    required init(viewController: SHShoutDetailTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let shoutID = self.viewController.shoutID {
            getShoutDetails(shoutID)
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
    
    func getShoutDetails(shoutID: String) {
        shApiShout.loadShoutDetail(shoutID, cacheResponse: { (shShout) -> Void in
            self.updateUI(shShout)
            }) { (response) -> Void in
                switch response.result {
                case .Success(let result):
                    self.updateUI(result)
                case .Failure(let error):
                    log.error("Unable to get the Shout Details \(error.localizedDescription)")
                }
        }
    }
    
    // UICollectioViewDataSource
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (self.shoutDetail?.videos.count > 0) {
            if(indexPath.row < self.shoutDetail?.videos.count) {
                if let video = self.shoutDetail?.videos[indexPath.row] {
                    if(video.provider == "youtube") {
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHYouTubeVideoCollectionViewCell, forIndexPath: indexPath) as! SHYouTubeVideoCollectionViewCell
                        let playerVars = ["playsinline" : 1,
                            "modestbranding" : 1,
                            "showinfo" : 0,
                            "controls" : 1,
                            "iv_load_policy" : 3,
                            "rel" : 0,
                            "theme" : "light"
                        ]
                        
                        cell.ytPlayerView.loadWithVideoId(video.idOnProvider, playerVars: playerVars)
                        cell.ytPlayerView.delegate = self
                        cell.ytPlayerView.webView.backgroundColor = UIColor.darkGrayColor()
                        return cell
                    } else if(video.provider == "shoutit_s3") {
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHAmazonVideoCollectionViewCell, forIndexPath: indexPath) as! SHAmazonVideoCollectionViewCell
                        cell.setVideo(video)
                        return cell
                    }
                }
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHShoutDetailImageCollectionViewCell, forIndexPath: indexPath) as! SHShoutDetailImageCollectionViewCell
                if let shoutDetail = self.shoutDetail where shoutDetail.images.count > 0 {
//                    cell.shoutImageView.kf_setImageWithURL(<#T##URL: NSURL##NSURL#>, placeholderImage: <#T##UIImage?#>)
                }
//                if(self.shoutDetail?.images.count > 0) {
//                    cell.shoutImageView.kf_setImageWithURL(NSURL(string: self.shoutDetail?.images[indexPath.row - self.shoutDetail?.videos.count])?, placeholderImage: <#T##UIImage?#>)
//                    
//                }
                
//                SHShoutDetailImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SHShoutDetailImageCollectionViewCell" forIndexPath:indexPath];
//                
//                if (self.shoutModel.shout.images.count > 0)
//                {
//                    [cell.shoutImageView setImageWithURL:[NSURL URLWithString:[self.shoutModel.shout.images[indexPath.row - self.shoutModel.shout.videos.count] largeImage]] placeholderImage:[UIImage imageNamed:@"logo.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//                    cell.imageURL = [self.shoutModel.shout.images[indexPath.row - self.shoutModel.shout.videos.count] largeImage];
//                }
//                else{
//                    [cell.shoutImageView setImage:[UIImage imageNamed:@"no_image_available"]];
//                }
//                
//                
//                return cell;
                
            }
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHShoutDetailImageCollectionViewCell, forIndexPath: indexPath) as! SHShoutDetailImageCollectionViewCell
        cell.shoutImageView.image = UIImage(named: "no_image_available")
        
//        SHShoutDetailImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SHShoutDetailImageCollectionViewCell" forIndexPath:indexPath];
        
//        if (self.shoutModel.shout.images.count > 0)
//        {
//            [cell.shoutImageView setImageWithURL:[NSURL URLWithString:[self.shoutModel.shout.images[indexPath.row] largeImage]] placeholderImage:[UIImage imageNamed:@"logo.png"]  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        }
//        else{
//            [cell.shoutImageView setImage:[UIImage imageNamed:@"no_image_available"]];
//        }
        
        return cell;
    }

    // MARK Private
    private func updateUI (shout: SHShout) {
        self.shoutDetail = shout
        self.viewController.collectionView.reloadData()
    }

}
