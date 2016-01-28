//
//  SHShoutDetailTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 22/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser
import MapKit
import Social
import MessageUI
import FBSDKShareKit
import DWTagList
import SVProgressHUD

class SHShoutDetailTableViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, YTPlayerViewDelegate, MWPhotoBrowserDelegate, MKMapViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, DWTagListDelegate{

    private let viewController: SHShoutDetailTableViewController
    private let shApiShout = SHApiShoutService()
    private var shoutDetail: SHShout?
    private var photos:[MWPhoto] = []
    private var reportTextField: UITextField?
    private var relatedShouts: [SHShout] = []
    private var toUpdate = false

    required init(viewController: SHShoutDetailTableViewController) {
        self.viewController = viewController
    }

    func viewDidLoad() {
        if let shoutID = self.viewController.shoutID {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDetails", name: "ShoutUpdated\(shoutID)", object: nil)
            getShoutDetails(shoutID)
        }
    }

    func viewWillAppear() {

    }

    func viewDidAppear() {
        if let shoutID = self.viewController.shoutID where self.toUpdate {
            getShoutDetails(shoutID)
        }
    }

    func viewWillDisappear() {

    }

    func viewDidDisappear() {

    }

    func destroy() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateDetails() {
        toUpdate = true
    }
    // ReplyAction
    func replyAction () {
        let messageViewController = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMESSAGES) as! SHMessagesViewController
        messageViewController.isFromShout = true
//      [messageViewController setShout:self.shoutModel.shout];
        messageViewController.shout = self.shoutDetail
        messageViewController.title = self.viewController.title
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromTop
        self.viewController.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.viewController.navigationController?.pushViewController(messageViewController, animated: false)
    }
    
    // Shout Contact Profile Action
    func contactProfileAction () {
        if let shoutUser = self.shoutDetail?.user {
            if(shoutUser.username != SHOauthToken.getFromCache()?.user?.username) {
                let profileViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPROFILE) as! SHProfileCollectionViewController
                profileViewController.requestUser(shoutUser)
                self.viewController.navigationController?.pushViewController(profileViewController, animated: true)
            } 
        }
    }
    
    // Report Action
    func reportAction() {
        if let shout = self.shoutDetail {
            let alert = UIAlertController(title: "Report \(shout.title)", message: "", preferredStyle:
                UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                if let reportedtext = self.reportTextField?.text, let shoutId = shout.id {
                    self.shApiShout.reportShout(reportedtext, shoutID: shoutId, completionHandler: { (shSuccess) -> Void in
                        switch (shSuccess.result) {
                        case .Success( _):
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                SHProgressHUD.showError(NSLocalizedString("Thank you! Shout has been reported as inappropriate and will be reviewed.", comment: "Report"), maskType: .Black)
                            }
                        case .Failure(let error):
                            log.error("Error posting the Report Inappropriate \(error.localizedDescription)")
                        }
                    })
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func configurationTextField(textField: UITextField!) {
        self.reportTextField = textField
        self.reportTextField?.placeholder = NSLocalizedString("Tell us what is wrong", comment: "Tell us what is wrong")
    }

    //Action Sheet
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if(actionSheet.tag != 2) {
            return
        }
        if(buttonIndex == actionSheet.cancelButtonIndex) {
            return
        }

        if let shout = self.shoutDetail {
            switch(buttonIndex) {
                case 1:
//                    let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
//                    content.contentURL = NSURL(string: shout.webUrl)
//                    content.contentTitle = shout.title
//                    content.contentDescription = shout.text
//                    content.imageURL = NSURL(string: shout.images[0])
//                    FBSDKShareDialog.showFromViewController(self.viewController, withContent: content, delegate: nil)
                    let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    vc.setInitialText(shout.title)
                    if let apiUrl = shout.apiUrl {
                        vc.addURL(NSURL(string: apiUrl))
                    }
                    self.viewController.presentViewController(vc, animated: true, completion: nil)

                case 2:
                break
                    // Google Share
                    // Construct the Google+ share URL
//
//                    NSURLComponents* urlComponents = [[NSURLComponents alloc]
//                        initWithString:@"https://plus.google.com/share"];
//                    urlComponents.queryItems = @[[[NSURLQueryItem alloc]
//                    initWithName:@"url"
//                    value:[shareURL absoluteString]]];
//                    NSURL* url = [urlComponents URL];
//
//                    if ([SFSafariViewController class]) {
//                        // Open the URL in SFSafariViewController (iOS 9+)
//                        SFSafariViewController* controller = [[SFSafariViewController alloc]
//                            initWithURL:url];
//                        controller.delegate = self;
//                        [self presentViewController:controller animated:YES completion:nil];
//                    } else {
//                        // Open the URL in the device's browser
//                        [[UIApplication sharedApplication] openURL:url];
              //  }

                case 3:
                    if(MFMailComposeViewController.canSendMail()) {
                        let composeViewController = MFMailComposeViewController(nibName: nil, bundle: nil)
                        composeViewController.mailComposeDelegate = self
                        if let webUrl = shout.webUrl {
                            composeViewController.setMessageBody(webUrl, isHTML: false)
                        }
                        self.viewController.presentViewController(composeViewController, animated: true, completion: nil)
                    }
                case 4:
                    var sharingItems = [String]()
                    if let webUrl = shout.webUrl {
                        sharingItems.append(webUrl)
                    }
                    let activityController = UIActivityViewController.init(activityItems: sharingItems, applicationActivities: nil)
                    self.viewController.presentViewController(activityController, animated: true, completion: nil)
                default:
                    break
            }
        }

    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    // MapView Overlay
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleR = MKCircleRenderer(overlay: overlay)
        circleR.fillColor = UIColor(shoutitColor: .ShoutGreen)
        circleR.alpha = 0.5
        circleR.lineWidth = 1
        circleR.strokeColor = UIColor(shoutitColor: .ShoutGreen)
        return circleR
    }

    // Photo Browser
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }

    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if(index < UInt(self.photos.count)) {
            return self.photos[Int(index)]
        }
        return nil
    }

    func getShoutDetails(shoutID: String) {
        SHProgressHUD.show(NSLocalizedString("Loading", comment: "Loading..."), maskType: .Black)
        self.photos = [MWPhoto]()
        if let images = shoutDetail?.images {
            for stringUrl in images {
                self.photos.append(MWPhoto(URL: NSURL(string: stringUrl)))
            }
        }
        shApiShout.loadShoutDetail(shoutID, cacheResponse: { (shShout) -> Void in
            if !self.toUpdate {
                SHProgressHUD.dismiss()
                self.updateUI(shShout)
            }
            }) { (response) -> Void in
                self.toUpdate = false
                SHProgressHUD.dismiss()
                switch response.result {
                case .Success(let result):
                    self.updateUI(result)
                case .Failure(let error):
                    log.error("Unable to get the Shout Details \(error.localizedDescription)")
                }
        }
    }

    func editShout(sender: AnyObject) {
        let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: NSLocalizedString("Delete", comment: "Delete"), otherButtonTitles: NSLocalizedString("Edit", comment: "Edit"))
        sheet.tag = 10
        sheet.showInView(self.viewController.view)
    }


    // UICollectioViewDataSource
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width, collectionView.frame.size.height)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCollectionViewCount()
    }

    func getCollectionViewCount() -> Int {
        if let images = self.shoutDetail?.images, let videos = self.shoutDetail?.videos {
            return images.count + videos.count
        }
        return 1
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
                    cell.shoutImageView.setImageWithURL(NSURL(string: shoutDetail.images[indexPath.row - shoutDetail.videos.count]), placeholderImage: UIImage(named: "logo"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    cell.imageURL = shoutDetail.images[indexPath.row - shoutDetail.videos.count]
                } else {
                    cell.shoutImageView.image = UIImage(named: "logo")
                }
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHShoutDetailImageCollectionViewCell, forIndexPath: indexPath) as! SHShoutDetailImageCollectionViewCell
            if (self.shoutDetail?.images.count > 0) {
                if let url = self.shoutDetail?.images[indexPath.row] {
                    cell.shoutImageView.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "logo"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                }
            } else {
                cell.shoutImageView.image = UIImage(named: "logo")
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            var browser = MWPhotoBrowser(delegate: self)
            // Set Options
            // Show action button to allow sharing, copying, etc (defaults to YES)
            browser.displayActionButton = false
            // Whether to display left and right nav arrows on toolbar (defaults to NO)
            browser.displayNavArrows = false
            // Whether selection buttons are shown on each image (defaults to NO)
            browser.displaySelectionButtons = false
            // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
            browser.zoomPhotosToFill = true
            // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
            browser.alwaysShowControls = false
            // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
            browser.enableGrid = true
            // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
            browser.startOnGrid = false

            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                if(cell.isKindOfClass(SHShoutDetailImageCollectionViewCell)) {
                    var ind = indexPath.row
                    if let videoCount = self.shoutDetail?.videos.count {
                        ind -= videoCount
                    }
                    browser.navigationController?.navigationBar.tintColor = UIColor(shoutitColor: .ShoutGreen)
                    browser.navigationController?.navigationBar.opaque = true
                    browser.setCurrentPhotoIndex(UInt(ind))

                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionFade
                    transition.subtype = kCATransitionFromTop
                    self.viewController.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
                    self.viewController.navigationController?.pushViewController(browser, animated: true)
                    browser = nil
                }

            }



        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.viewController.collectionView.frame.size.width
        self.viewController.pageControl.currentPage = Int((self.viewController.collectionView.contentOffset.x + (pageWidth) / 2.0) / pageWidth)
    }

    // Suggested Shouts Tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Suggested Shouts", comment: "Suggested Shouts")
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.relatedShouts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as! SHShoutTableViewCell
        let shout = self.relatedShouts[indexPath.row]
        cell.setShout(shout)
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as! SHShoutDetailTableViewController
        detailView.title = self.relatedShouts[indexPath.row].title
        if let shoutId = self.relatedShouts[indexPath.row].id {
            detailView.getShoutDetails(shoutId)
        }
        self.viewController.navigationController?.pushViewController(detailView, animated: true)
    }

    //Tags Selected
    func selectedTag(tagName: String!, tagIndex: Int) {
        if let streamVC = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.STREAM_VC) as? SHStreamTableViewController {
            streamVC.streamType = .Tag
            streamVC.tagName = tagName
            streamVC.title = tagName
            self.viewController.navigationController?.pushViewController(streamVC, animated: true)
        }
    }

    func selectedTag(tagName: String!) {
        log.verbose(tagName)
    }

    func tagListTagsChanged(tagList: DWTagList!) {

    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if(actionSheet.tag == 10) {
            if(buttonIndex == 0) {
                let ac = UIAlertController(title: NSLocalizedString("Delete", comment: "Delete"), message: NSLocalizedString("Delete the shout?", comment: "Delete the shout?"), preferredStyle: UIAlertControllerStyle.Alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                    if let shout = self.shoutDetail, let shoutId = shout.id{
                        self.shApiShout.deleteShoutID(shoutId, completionHandler: { (response) -> Void in
                            if(response.result.isSuccess) {
                                self.viewController.navigationController?.popViewControllerAnimated(true)
                                NSNotificationCenter.defaultCenter().postNotificationName("shoutDeleted", object: true)
                            } else {
                                log.verbose("Error deleting the shout: \(shoutId)")
                            }
                        })
                    }
                }))
                ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
                self.viewController.presentViewController(ac, animated: true, completion: nil)
            } else if(buttonIndex == 2) {
                if let shout = self.shoutDetail {
                    SHCreateShoutTableViewController.presentEditorFromViewController(self.viewController, shout: shout)
                }
            }
        }
    }

    // MARK Private
    private func updateUI(shoutDetail: SHShout) {
        self.shoutDetail = shoutDetail
        updateShoutInfo(shoutDetail)
        if let shoutId = shoutDetail.id {
            getRelatedShouts(shoutId)
        }
    }
    
    private func getRelatedShouts(shoutID: String) {
        shApiShout.loadRelatedShout(shoutID, cacheResponse: { (shShout) -> Void in
            self.updateRelatedShouts(shShout)
            }) { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.updateRelatedShouts(result)
                case .Failure(let error):
                    log.error("Error fetching related Shouts \(error.localizedDescription)")
                }
                
        }
    }
    
    private func updateRelatedShouts(shout: SHShoutMeta) {
        self.relatedShouts = shout.results
        self.viewController.tableView.reloadData()
        self.viewController.collectionView.reloadData()
    }

    private func updateShoutInfo(shoutDetail: SHShout) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")

            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            if let number = numberFormatter.numberFromString(String(format: "%g", shoutDetail.price)) {
                let price = String(format: "%@ %@", shoutDetail.currency, number.stringValue)
                self.viewController.priceLabel.text = price
            }

            if let datePublished = self.shoutDetail?.datePublished  {
                self.viewController.timeLabel.text = datePublished.timeAgoSimple
            }
            self.viewController.descriptionTextView.text = shoutDetail.text

            if(shoutDetail.location?.state != "") {
                if let city = shoutDetail.location?.city, let state = shoutDetail.location?.state, let country = shoutDetail.location?.country {
                    self.viewController.locationLabel.text = String(format: "%@, %@, %@", arguments: [city, state, country])
                }
            } else {
                if let city = shoutDetail.location?.city, let country = shoutDetail.location?.country {
                    self.viewController.locationLabel.text = String(format: "%@, %@", arguments: [city, country])
                }
            }
            self.viewController.titleLabel.text = shoutDetail.title
            self.viewController.typeLabel.text = shoutDetail.type.rawValue
            if(shoutDetail.type == ShoutType.Offer) {
                self.viewController.typeLabel.textColor = UIColor(shoutitColor: .ShoutGreen)
            } else {
                self.viewController.typeLabel.textColor = UIColor(shoutitColor: .ShoutRed)
            }
            if shoutDetail.stringTags.isEmpty, let tags = shoutDetail.tags {
                shoutDetail.stringTags = tags.map({ (tag) -> String in
                    tag.name
                })
            }
            self.viewController.tagList.setTags(shoutDetail.stringTags)
            self.viewController.categoryLabel.text = shoutDetail.category?.name
            self.viewController.pageControl.numberOfPages = self.getCollectionViewCount()

            if let userImage = shoutDetail.user?.image , let imageUrl = NSURL(string: userImage) {
                self.viewController.profileImageView.kf_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "no_image_available"))
            }
            self.photos = [MWPhoto]()
            for stringUrl in shoutDetail.images {
                if let url = NSURL(string: stringUrl) {
                    self.photos.append(MWPhoto(URL: url))
                }
            }
            self.viewController.profileButton.setTitle(self.shoutDetail?.user?.name, forState: UIControlState.Normal)

            if let lat = shoutDetail.location?.latitude, let long = shoutDetail.location?.longitude {
                let coord = CLLocationCoordinate2DMake(Double(lat), Double(long))

                let circle = MKCircle(centerCoordinate: coord, radius: 400)
                self.viewController.mapView.addOverlay(circle)

                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegion(center: coord, span: span)
                self.viewController.mapView.setRegion(region, animated: true)
                self.viewController.mapView.addOverlay(circle)
            }
            self.recalculateHeaderViewSize()
            self.viewController.tableView.reloadData()
            self.viewController.collectionView.reloadData()

            // NavBar
            if(shoutDetail.user?.username == SHOauthToken.getFromCache()?.user?.username) {
                self.viewController.navigationItem.rightBarButtonItem = nil
                let item = UIBarButtonItem(image: UIImage(named: "more_item"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editShout:"))
                self.viewController.navigationItem.rightBarButtonItem = item
            }

        }
    }

    private func recalculateHeaderViewSize () {
        var tag = self.viewController.tagList.frame
        self.viewController.descriptionTextView.sizeToFit()
        var desc = self.viewController.descriptionTextView.frame
        desc.size.height += 1
        tag.size = self.viewController.tagList.contentSize

        self.viewController.titleLabel.numberOfLines = 0
        self.viewController.titleLabel.sizeToFit()
        self.viewController.tagListHeight.constant = tag.size.height
        self.viewController.descriptionHeight.constant  = desc.size.height
        self.viewController.titleHeight.constant = self.viewController.titleLabel.frame.size.height
        self.viewController.tableView.layoutIfNeeded()
        let report = self.viewController.reportButton.frame.origin.y + self.viewController.reportButton.frame.size.height
        if var head = self.viewController.tableView.tableHeaderView?.frame {
            if(head.size.height - 20 <= report) {
                head.size.height = report + 20
            }
            let temp = self.viewController.tableView.tableHeaderView
            self.viewController.tableView.tableHeaderView = nil
            temp?.frame = head
            temp?.layoutIfNeeded()
            self.viewController.tableView.tableHeaderView = temp
            self.viewController.tableView.layoutIfNeeded()
        }
    }

}
