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
import ShoutitKit

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
                .subscribe(onNext: {[weak self] in
                    self?.tableView.reloadData()
                    self?.hydrateHeader()
                })
                .addDisposableTo(disposeBag)
            
            viewModel
                .reloadOtherShoutsSubject
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] in
                    self?.dataSource.otherShoutsCollectionView?.reloadData()
                })
                .addDisposableTo(disposeBag)
            
            viewModel
                .reloadRelatedShoutsSubject
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] in
                    self?.dataSource.relatedShoutsCollectionView?.reloadData()
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    // RX
    fileprivate var headerDisposeBag = DisposeBag()
    let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // data sources
    fileprivate var dataSource: ShoutDetailTableViewDataSource! {
        didSet {
            tableView.dataSource = dataSource
            
            dataSource.otherShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (collectionView) in
                    collectionView.dataSource = self?.otherShoutsDataSource
                    collectionView.delegate = self
                })
                .addDisposableTo(disposeBag)
            
            dataSource.relatedShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (collectionView) in
                    collectionView.dataSource = self?.relatedShoutsDataSource
                    collectionView.delegate = self
                    if #available(iOS 9.0, *) {
                        collectionView.semanticContentAttribute = .forceLeftToRight
                    }
                    if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                        collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    }
                })
                .addDisposableTo(disposeBag)
            
        }
    }
    fileprivate var otherShoutsDataSource: ShoutDetailOtherShoutsCollectionViewDataSource!
    fileprivate var relatedShoutsDataSource: ShoutDetailRelatedShoutsCollectionViewDataSource!
    fileprivate var imagesDataSource: ShoutDetailImagesPageViewControllerDataSource! {
        didSet {
            photosPageViewController.dataSource = imagesDataSource
            photosPageViewController.delegate = imagesDataSource
        }
    }
    
    // children
    fileprivate var photosPageViewController: PhotoBrowserPageViewController!
    
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
        
        imagesDataSource.showDetailOfMedia.asDriver(onErrorJustReturn: .loading).drive(onNext: { [weak self] (viewModel) in
            self?.showMediaPreviewWithSelectedMedia(viewModel)
        }).addDisposableTo(disposeBag)
        
        // display data
        hydrateHeader()
        showNativeAd()
        
        self.likeButton.isHidden = Account.sharedInstance.user?.isGuest == true
    }
    
    func updateLikeButtonState() {
        if viewModel.shout.isLiked ?? false {
            self.likeButton.setLiked()
        } else {
            self.likeButton.setUnliked()
        }
    }
    
    func updateBookmarkButtonState() {
        if viewModel.shout.isBookmarked ?? false {
            self.bookmarkButton.setImage(UIImage(named: "bookmark_on"), for: UIControlState())
        } else {
            self.bookmarkButton.setImage(UIImage(named: "bookmark_off"), for: UIControlState())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadShoutDetails()
    }
    
    //FBAudienceImplementaion
    
    func bindWithAd(_ nativeAd: FBNativeAd) {
        
        if let title = nativeAd.title {
            self.adTitlelabel.text = title
        }
        
        if let body = nativeAd.body {
            self.adBodyLabel.text = body
        }
        
        if let callToAction = nativeAd.callToAction {
            self.adCallToActionButton.isHidden = false
            self.adCallToActionButton.setTitle(callToAction, for: UIControlState())
        } else {
            self.adCallToActionButton.isHidden = true
        }
        
        nativeAd.icon?.loadAsync(block: { [weak self] (image) -> Void in
            self?.adIconImageView?.image = image
        })
        self.adCoverMediaView.nativeAd = nativeAd
        
        self.adChoicesView.nativeAd = nativeAd
        self.adChoicesView.corner = .topRight
        self.adChoicesView.isHidden = false
        
        nativeAd.registerView(forInteraction: self.adUIView, with: self)
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: NSError) {
        print("Ad failed to load with error: %@", error)
        adBGView.isHidden = true
        adUIView.isHidden = true
        
//        DDLogError("FACEBOOK_AUDIENCE: \(error)")
    }
    
    var nativeAd: FBNativeAd!
    
    func showNativeAd() {
        nativeAd = FBNativeAd(placementID: Constants.FacebookAudience.detailAdID)
        nativeAd.delegate = self
        nativeAd.load()
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
//        DDLogVerbose("FACEBOOK_AUDIENCE: Ad Loaded - \(nativeAd.placementID)")
        bindWithAd(nativeAd)
    }
    
    // MARK: - Setup
    
    fileprivate func hydrateHeader() {
        headerView.authorNameLabel.text = viewModel.shout.user?.name
        headerView.authorProfileImageView.sh_setImageWithURL(viewModel.shout.user?.imagePath?.toURL(), placeholderImage: viewModel.shout.user?.type == .Page ? UIImage.squareAvatarPagePlaceholder() : UIImage.squareAvatarPlaceholder())
        
        headerView.locationLabel.text = viewModel.locationString()
        headerView.shoutTypeLabel.text = viewModel.shout.type()?.title()
        headerView.titleLabel.text = viewModel.shout.title
        headerView.priceLabel.text = viewModel.priceString()
        headerView.availabilityLabel.text = ""
        
        headerDisposeBag = DisposeBag()
        headerView.showProfileButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                guard let user = self.viewModel.shout.user else { return }
                self.flowDelegate?.showProfile(user)
            })
            .addDisposableTo(headerDisposeBag)
        
        let visible = viewModel.priceString() != nil && !viewModel.priceString()!.isEmpty
        headerView.setConstraintForPriceLabelVisible(visible)
        
        if let firstImageController = self.imagesDataSource.firstViewController() {
            photosPageViewController.setViewControllers([firstImageController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            imagesDataSource.updatePageControlWithPageViewController(photosPageViewController, currentController: nil)
        }
        
        // size
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if !size.equalTo(headerView.frame.size) {
            headerView.frame = CGRect(x: 0, y: 0, width: headerView.bounds.width, height: size.height)
            tableView.tableHeaderView = headerView
        }
        
        updateLikeButtonState()
        updateBookmarkButtonState()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? PhotoBrowserPageViewController {
            photosPageViewController = pageViewController
        }
    }
}


extension ShoutDetailTableViewController : MWPhotoBrowserDelegate {
    fileprivate func showMediaPreviewWithSelectedMedia(_ selectedMedia: ShoutDetailShoutImageViewModel) {
        guard selectedMedia.canShowPreview() else {
            return
        }
        
        let photoBrowser = PhotoBrowser(photos: imagesDataSource.viewModel.imagesViewModels.flatMap{$0.mwPhoto()})

        photoBrowser?.delegate = self
        
        let idx : UInt
        
        if self.photosPageViewController.pageControl.currentPage > 0 {
            idx = UInt(self.photosPageViewController.pageControl.currentPage as Int)
        } else {
            idx = 0
        }
        
        photoBrowser?.setCurrentPhotoIndex(idx)
        
        self.navigationController?.show(photoBrowser!, sender: nil)
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(imagesDataSource.viewModel.imagesViewModels.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        let photos = imagesDataSource.viewModel.imagesViewModels.flatMap{$0.mwPhoto()}
        
        return photos[Int(index)]
    }
}

// MARK: - UITableViewDelegate

extension ShoutDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = viewModel.cellModels[indexPath.row]
        switch cellModel {
        case .keyValue(_, _, _, _, _, let filter?, _):
            self.flowDelegate?.showTag(filter)
        case .keyValue(_, _, _, _, _, _, let tag?):
            self.flowDelegate?.showTag(tag)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = viewModel.cellModels[indexPath.row]
        switch cellModel {
        case .sectionHeader:
            return 54
        case .description(let description):
            let horizontalMargins: CGFloat = 2 * 20
            let verticalMargins: CGFloat = 2 * 10
            let availableWidth = tableView.bounds.width - horizontalMargins
            let size = (description as NSString).boundingRect(with: CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude),
                                                                      options: [NSStringDrawingOptions.usesLineFragmentOrigin],
                                                                      attributes: [NSFontAttributeName : UIFont.sh_systemFontOfSize(14, weight: .regular)],
                                                                      context: nil).size
            return size.height + verticalMargins
        case .keyValue:
            return 40
        case .regular:
            return 40
        case .button:
            return 49
        case .otherShouts:
            return dataSource.otherShoutsHeight
        case .relatedShouts:
            return 130
        }
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assertionFailure()
            return
        }
        
        let cellViewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        
        switch cellViewModels[indexPath.row] {
        case .content(let shout):
            flowDelegate?.showShout(shout)
        case .seeAll:
            flowDelegate?.showRelatedShoutsForShout(viewModel.shout)
        default:
            break
        }
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assert(false)
            return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
        
        let viewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        if let first = viewModels.first, case ShoutDetailShoutCellViewModel.content = first {
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
    
    @IBAction func likeButtonAction(_ sender: LikeButton) {
        if viewModel.shout.isLiked ?? false {
            unlikeShout()
        } else {
            likeShout()
        }

    }
    
    func likeShout() {
        APIShoutsService.likeShout(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .next(let success):
                self?.showSuccessMessage(success.message)
                
                if let likedShout = self?.viewModel.shout.copyWithLiked(true) {
                    self?.viewModel.reloadShout(likedShout)
                    self?.updateLikeButtonState()
                }
            case .error(let error):
                self?.showError(error)
            default: break
                
            }
        }.addDisposableTo(disposeBag)
    }
    
    func unlikeShout() {
        APIShoutsService.unlikeShout(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .next(let success):
                self?.showSuccessMessage(success.message)
                
                if let likedShout = self?.viewModel.shout.copyWithLiked(false) {
                    self?.viewModel.reloadShout(likedShout)
                    self?.updateLikeButtonState()
                }
                
            case .error(let error):
                self?.showError(error)
            default: break
                
            }
        }.addDisposableTo(disposeBag)
    }
    
    
    @IBAction func bookmarkButtonAction(_ sender: UIButton) {
        if viewModel.shout.isBookmarked ?? false {
            removeFromBookmarks()
        } else {
            bookMarkShout()
        }
    }
    
    func bookMarkShout() {
        BookmarkManager.addShoutToBookmarks(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .next(let success):
                self?.showSuccessMessage(success.message)
                if let newShout = self?.viewModel.shout.copyWithBookmark(true) {
                    self?.viewModel.reloadShout(newShout)
                }
            case .error(let error):
                self?.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func removeFromBookmarks() {
        BookmarkManager.removeFromBookmarks(viewModel.shout).subscribe { [weak self] (event) in
            switch event {
            case .next(let success):
                self?.showSuccessMessage(success.message)
                if let newShout = self?.viewModel.shout.copyWithBookmark(false) {
                    self?.viewModel.reloadShout(newShout)
                }
            case .error(let error):
                self?.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
}
