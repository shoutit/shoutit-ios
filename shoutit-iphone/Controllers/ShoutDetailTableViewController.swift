//
//  ShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import FBAudienceNetwork

final class ShoutDetailTableViewController: UITableViewController, FBNativeAdDelegate {
    
    // UI
    @IBOutlet var headerView: ShoutDetailTableHeaderView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    //AdUI
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adTitlelabel: UILabel!
    @IBOutlet weak var adBodyLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var adChoicesView: FBAdChoicesView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adUIView: UIView!
    @IBOutlet weak var adBGView: UIView!
    
    // view model
    var viewModel: ShoutDetailViewModel! {
        didSet {
            viewModel
                .reloadObservable
                .observeOn(MainScheduler.instance)
                .subscribeNext {[weak self] in
                    self?.tableView.reloadData()
                    self?.hydrateHeader()
                }
                .addDisposableTo(disposeBag)
            
            viewModel
                .reloadOtherShoutsSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext {[weak self] in
                    self?.dataSource.otherShoutsCollectionView?.reloadData()
                }
                .addDisposableTo(disposeBag)
            
            viewModel
                .reloadRelatedShoutsSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext {[weak self] in
                    self?.dataSource.relatedShoutsCollectionView?.reloadData()
                }
                .addDisposableTo(disposeBag)
        }
    }
    
    // RX
    private var headerDisposeBag = DisposeBag()
    let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // data sources
    private var dataSource: ShoutDetailTableViewDataSource! {
        didSet {
            tableView.dataSource = dataSource
            
            dataSource.otherShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (collectionView) in
                    collectionView.dataSource = self?.otherShoutsDataSource
                    collectionView.delegate = self
                }
                .addDisposableTo(disposeBag)
            
            dataSource.relatedShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (collectionView) in
                    collectionView.dataSource = self?.relatedShoutsDataSource
                    collectionView.delegate = self
                    if #available(iOS 9.0, *) {
                        collectionView.semanticContentAttribute = .ForceLeftToRight
                    }
                    if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
                        collectionView.transform = CGAffineTransformMakeScale(-1, 1)
                    }
                }
                .addDisposableTo(disposeBag)
            
        }
    }
    private var otherShoutsDataSource: ShoutDetailOtherShoutsCollectionViewDataSource!
    private var relatedShoutsDataSource: ShoutDetailRelatedShoutsCollectionViewDataSource!
    private var imagesDataSource: ShoutDetailImagesPageViewControllerDataSource! {
        didSet {
            photosPageViewController.dataSource = imagesDataSource
            photosPageViewController.delegate = imagesDataSource
        }
    }
    
    // children
    private var photosPageViewController: PhotoBrowserPageViewController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        // setup data sources
        dataSource = ShoutDetailTableViewDataSource(controller: self)
        otherShoutsDataSource = ShoutDetailOtherShoutsCollectionViewDataSource(controller: self)
        relatedShoutsDataSource = ShoutDetailRelatedShoutsCollectionViewDataSource(controller: self)
        imagesDataSource = ShoutDetailImagesPageViewControllerDataSource(controller: self)
        
        imagesDataSource.showDetailOfMedia.asDriver(onErrorJustReturn: .Loading).driveNext { [weak self] (viewModel) in
            self?.showMediaPreviewWithSelectedMedia(viewModel)
        }.addDisposableTo(disposeBag)
        
        // display data
        hydrateHeader()
        showNativeAd()
    }
    
    func updateLikeButtonState() {
        if viewModel.shout.isLiked {
            self.likeButton.setLiked()
        } else {
            self.likeButton.setUnliked()
        }
    }
    
    func updateBookmarkButtonState() {
        if viewModel.shout.isBookmarked {
            self.bookmarkButton.setImage(UIImage(named: "bookmark_on"), forState: .Normal)
        } else {
            self.bookmarkButton.setImage(UIImage(named: "bookmark_off"), forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadShoutDetails()
    }
    
    //FBAudienceImplementaion
    
    func bindWithAd(nativeAd: FBNativeAd) {
        
        if let title = nativeAd.title {
            self.adTitlelabel.text = title
        }
        
        if let body = nativeAd.body {
            self.adBodyLabel.text = body
        }
        
        if let callToAction = nativeAd.callToAction {
            self.adCallToActionButton.hidden = false
            self.adCallToActionButton.setTitle(callToAction, forState: .Normal)
        } else {
            self.adCallToActionButton.hidden = true
        }
        
        nativeAd.icon?.loadImageAsyncWithBlock({(image) -> Void in
            self.adIconImageView?.image = image
        })
        self.adCoverMediaView.nativeAd = nativeAd
        
        self.adChoicesView.nativeAd = nativeAd
        self.adChoicesView.corner = .TopRight
        self.adChoicesView.hidden = false
        
        nativeAd.registerViewForInteraction(self.adUIView, withViewController: self)
    }
    
    func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError) {
        print("Ad failed to load with error: %@", error)
        adBGView.hidden = true
        adUIView.hidden = true
    }
    
    var nativeAd: FBNativeAd!
    
    func showNativeAd() {
        nativeAd = FBNativeAd(placementID: "1151546964858487_1249823215030861")
        nativeAd.delegate = self
        nativeAd.loadAd()
    }
    
    func nativeAdDidLoad(nativeAd: FBNativeAd) {
        
        if nativeAd == "" {
            adUIView.hidden = true
        }
        bindWithAd(nativeAd)
    }
    
    // MARK: - Setup
    
    private func hydrateHeader() {
        headerView.authorNameLabel.text = viewModel.shout.user?.name
        headerView.authorProfileImageView.sh_setImageWithURL(viewModel.shout.user?.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.locationLabel.text = viewModel.locationString()
        headerView.shoutTypeLabel.text = viewModel.shout.type()?.title()
        headerView.titleLabel.text = viewModel.shout.title
        headerView.priceLabel.text = viewModel.priceString()
        headerView.availabilityLabel.text = ""
        
        headerDisposeBag = DisposeBag()
        headerView.showProfileButton
            .rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                guard let user = self.viewModel.shout.user else { return }
                self.flowDelegate?.showProfile(user)
            }
            .addDisposableTo(headerDisposeBag)
        
        let visible = viewModel.priceString() != nil && !viewModel.priceString()!.isEmpty
        headerView.setConstraintForPriceLabelVisible(visible)
        
        if let firstImageController = self.imagesDataSource.firstViewController() {
            photosPageViewController.setViewControllers([firstImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            imagesDataSource.updatePageControlWithPageViewController(photosPageViewController, currentController: nil)
        }
        
        // size
        let size = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        if !CGSizeEqualToSize(size, headerView.frame.size) {
            headerView.frame = CGRect(x: 0, y: 0, width: headerView.bounds.width, height: size.height)
            tableView.tableHeaderView = headerView
        }
        
        updateLikeButtonState()
        updateBookmarkButtonState()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? PhotoBrowserPageViewController {
            photosPageViewController = pageViewController
        }
    }
}


extension ShoutDetailTableViewController : MWPhotoBrowserDelegate {
    private func showMediaPreviewWithSelectedMedia(selectedMedia: ShoutDetailShoutImageViewModel) {
        guard selectedMedia.canShowPreview() else {
            return
        }
        
        let photoBrowser = PhotoBrowser(photos: imagesDataSource.viewModel.imagesViewModels.flatMap{$0.mwPhoto()})

        photoBrowser.delegate = self
        
        let idx : UInt
        
        if self.photosPageViewController.pageControl.currentPage > 0 {
            idx = UInt(self.photosPageViewController.pageControl.currentPage as Int)
        } else {
            idx = 0
        }
        
        photoBrowser.setCurrentPhotoIndex(idx)
        
        self.navigationController?.showViewController(photoBrowser, sender: nil)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(imagesDataSource.viewModel.imagesViewModels.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let photos = imagesDataSource.viewModel.imagesViewModels.flatMap{$0.mwPhoto()}
        
        return photos[Int(index)]
    }
}

// MARK: - UITableViewDelegate

extension ShoutDetailTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellModel = viewModel.cellModels[indexPath.row]
        switch cellModel {
        case .KeyValue(_, _, _, _, _, let filter?, _):
            self.flowDelegate?.showTag(filter)
        case .KeyValue(_, _, _, _, _, _, let tag?):
            self.flowDelegate?.showTag(tag)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellModel = viewModel.cellModels[indexPath.row]
        switch cellModel {
        case .SectionHeader:
            return 54
        case .Description(let description):
            let horizontalMargins: CGFloat = 2 * 20
            let verticalMargins: CGFloat = 2 * 10
            let availableWidth = tableView.bounds.width - horizontalMargins
            let size = (description as NSString).boundingRectWithSize(CGSize(width: availableWidth, height: CGFloat.max),
                                                                      options: [NSStringDrawingOptions.UsesLineFragmentOrigin],
                                                                      attributes: [NSFontAttributeName : UIFont.sh_systemFontOfSize(14, weight: .Regular)],
                                                                      context: nil).size
            return size.height + verticalMargins
        case .KeyValue:
            return 40
        case .Regular:
            return 40
        case .Button:
            return 49
        case .OtherShouts:
            return dataSource.otherShoutsHeight
        case .RelatedShouts:
            return 130
        }
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assertionFailure()
            return
        }
        
        let cellViewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        
        switch cellViewModels[indexPath.row] {
        case .Content(let shout):
            flowDelegate?.showShout(shout)
        case .SeeAll:
            flowDelegate?.showRelatedShoutsForShout(viewModel.shout)
        default:
            break
        }
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assert(false)
            return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
        
        let viewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        if let first = viewModels.first, case ShoutDetailShoutCellViewModel.Content = first {
            let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            if index == 1 {
                return itemSize
            }
            
            let ratio = itemSize.height / itemSize.width
            let spacings: CGFloat = 3 * 10
            let numberOfColumns: CGFloat = 2
            let itemWidth = floor((collectionView.bounds.width - spacings) / numberOfColumns)
            let itemHeight = floor(itemWidth * ratio)
            return CGSize(width: itemWidth, height: itemHeight)
        }
        
        // placeholder size
        return CGSize(width: collectionView.bounds.width - 20, height: 120)
    }
    
    @IBAction func likeButtonAction(sender: LikeButton) {
        if viewModel.shout.isLiked {
            unlikeShout()
        } else {
            likeShout()
        }

    }
    
    func likeShout() {
        APIShoutsService.likeShout(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .Next(let success):
                self?.showSuccessMessage(success.message)
                
                if let likedShout = self?.viewModel.shout.copyWithLiked(true) {
                    self?.viewModel.reloadShout(likedShout)
                    self?.updateLikeButtonState()
                }
            case .Error(let error):
                self?.showError(error)
            default: break
                
            }
        }.addDisposableTo(disposeBag)
    }
    
    func unlikeShout() {
        APIShoutsService.unlikeShout(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .Next(let success):
                self?.showSuccessMessage(success.message)
                
                if let likedShout = self?.viewModel.shout.copyWithLiked(false) {
                    self?.viewModel.reloadShout(likedShout)
                    self?.updateLikeButtonState()
                }
                
            case .Error(let error):
                self?.showError(error)
            default: break
                
            }
        }.addDisposableTo(disposeBag)
    }
    
    
    @IBAction func bookmarkButtonAction(sender: UIButton) {
        if viewModel.shout.isBookmarked {
            removeFromBookmarks()
        } else {
            bookMarkShout()
        }
    }
    
    func bookMarkShout() {
        BookmarkManager.addShoutToBookmarks(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .Next(let success):
                self?.showSuccessMessage(success.message)
                if let newShout = self?.viewModel.shout.copyWithBookmark(true) {
                    self?.viewModel.reloadShout(newShout)
                }
            case .Error(let error):
                self?.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func removeFromBookmarks() {
        BookmarkManager.removeFromBookmarks(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .Next(let success):
                self?.showSuccessMessage(success.message)
                if let newShout = self?.viewModel.shout.copyWithBookmark(false) {
                    self?.viewModel.reloadShout(newShout)
                }
            case .Error(let error):
                self?.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
}
