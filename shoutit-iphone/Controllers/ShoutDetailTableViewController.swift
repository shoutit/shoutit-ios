//
//  ShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MWPhotoBrowser

protocol ShoutDetailTableViewControllerFlowDelegate: class, ShoutDisplayable, ChatDisplayable, ProfileDisplayable, TagDisplayable, SearchDisplayable, AllShoutsDisplayable {
    
}

final class ShoutDetailTableViewController: UITableViewController {
    
    // UI
    @IBOutlet var headerView: ShoutDetailTableHeaderView!
    
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
    let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: ShoutDetailTableViewControllerFlowDelegate?
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadShoutDetails()
    }
    
    // MARK: - Setup
    
    private func hydrateHeader() {
        headerView.authorNameLabel.text = viewModel.shout.user.name
        headerView.authorProfileImageView.sh_setImageWithURL(viewModel.shout.user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.locationLabel.text = viewModel.locationString()
        headerView.shoutTypeLabel.text = viewModel.shout.type()?.title()
        headerView.titleLabel.text = viewModel.shout.title
        headerView.priceLabel.text = viewModel.priceString()
        headerView.availabilityLabel.text = ""
        let visible = viewModel.priceString() != nil && !viewModel.priceString()!.isEmpty
        headerView.setConstraintForPriceLabelVisible(visible)
        
        photosPageViewController.setViewControllers(self.imagesDataSource.viewControllers(), direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        imagesDataSource.updatePageControlWithPageViewController(photosPageViewController, currentController: nil)
        
        // size
        let size = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        if !CGSizeEqualToSize(size, headerView.frame.size) {
            headerView.frame = CGRect(x: 0, y: 0, width: headerView.bounds.width, height: size.height)
            tableView.tableHeaderView = headerView
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? PhotoBrowserPageViewController {
            photosPageViewController = pageViewController
        }
    }
}

extension ShoutDetailTableViewController {
    private func showMediaPreviewWithSelectedMedia(selectedMedia: ShoutDetailShoutImageViewModel) {
        guard selectedMedia.canShowPreview() else {
            return
        }
        
        let medias : [MWPhoto] = Array.filterNils(self.imagesDataSource.viewModel.imagesViewModels.map { (model) -> MWPhoto? in
            return model.mwPhoto()
        })
        
        let photoBrowser = PhotoBrowser(photos: medias)

        let idx : UInt
        
        if self.photosPageViewController.pageControl.currentPage > 0 {
            idx = UInt(self.photosPageViewController.pageControl.currentPage as Int)
        } else {
            idx = 0
        }
        
        photoBrowser.setCurrentPhotoIndex(idx)
        
        self.navigationController?.showViewController(photoBrowser, sender: nil)
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
}

