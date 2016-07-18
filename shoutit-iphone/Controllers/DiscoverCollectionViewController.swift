//
//  DiscoverCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class DiscoverCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var viewModel : DiscoverViewModel!
    var disposeBag = DisposeBag()
    weak var flowDelegate: FlowController?
    
    var bookmarksDisposeBag : DisposeBag?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarksDisposeBag = DisposeBag()
        
        registerNibs()
        loadItems()
        
        self.viewModel.adManager.reloadCollection = {
            self.collectionView?.reloadData()
        }
        
        self.viewModel.adManager.reloadIndexPath = { indexPaths in
            self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
        }
        
        self.viewModel.adManager.shoutsSection = 1
    }
    
    func registerNibs() {
        self.collectionView?.registerNib(UINib(nibName: "DiscoverHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.SubItems.headerIdentifier())
        self.collectionView?.registerNib(UINib(nibName: "DiscoverShoutsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.Shouts.headerIdentifier())
        self.collectionView?.registerNib(UINib(nibName: "DiscoverShoutFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: DiscoverSection.Shouts.footerIdentifier())
        
        self.collectionView?.registerNib(UINib(nibName: "ShoutItemListCell", bundle: nil), forCellWithReuseIdentifier: ShoutCellsIdentifiers.ListReuseIdentifier.rawValue)
        self.collectionView?.registerNib(UINib(nibName: "ShoutItemGridCell", bundle: nil), forCellWithReuseIdentifier: ShoutCellsIdentifiers.GridReuseIdentifier.rawValue)
    }
    
    func loadItems() {
        if viewModel == nil {
            viewModel = DiscoverGeneralViewModel()
        }
        
        viewModel.items.asObservable().observeOn(MainScheduler.instance).subscribeNext {[weak self] (result) in
            self?.collectionView?.reloadData()
        }.addDisposableTo(disposeBag)
        
        viewModel.shouts.asObservable().observeOn(MainScheduler.instance).subscribeNext({ [weak self] (result) -> Void in
            self?.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        
        viewModel.retriveDiscoverItems()
        
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction(sender: AnyObject) {
        if let discoverItem = viewModel.mainItem() {
            flowDelegate?.showSearchInContext(.DiscoverShouts(item: discoverItem))
        } else {
            flowDelegate?.showSearchInContext(.General)
        }
    }
    
    // MARK: UICollectionView Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                flowDelegate?.showDiscoverForDiscoverItem(element)
            }
            return
        }
        
        if case .Shout(let shout) = self.viewModel.shoutItemsWithAds()[indexPath.item] {
            flowDelegate?.showShout(shout)
        }
    }

    // MARK: UICollectionView Data Source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.discoverItems().count
        }
        
        return viewModel.shoutItemsWithAds().count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.viewModel.cellIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
    
        
        // Configure Shout cell
        if indexPath.section == 1 {
            if case .Shout(let element) = self.viewModel.shoutItemsWithAds()[indexPath.item] {
                let shoutCell = cell as! SHShoutItemCell
                shoutCell.bindWith(Shout: element)
                shoutCell.bookmarkButton?.tag = indexPath.item
                shoutCell.bookmarkButton?.addTarget(self, action: #selector(HomeShoutsCollectionViewController.switchBookmarkState), forControlEvents: .TouchUpInside)
            }

            return cell
        }
        
        // Configure Discover cell
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.viewModel.cellIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                let discoverCell = cell as! SHShoutItemCell
                discoverCell.bindWith(DiscoverItem: element)
            }
            
            return cell
        }
        
        fatalError("Not supported section")
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer =  collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.footerIdentifier(), forIndexPath: indexPath)
            
            if let discoverFooter = footer as? DiscoverShoutFooterView {
                discoverFooter.showShoutsButton.addTarget(self, action: #selector(DiscoverCollectionViewController.showDiscoverShouts), forControlEvents: .TouchUpInside)
            }
            
            return footer
        }
        
        let header =  collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.headerIdentifier(), forIndexPath: indexPath)
        
        
        if let discoverHeader = header as? DiscoverHeaderView {
            let title = viewModel.mainItem()?.title ?? NSLocalizedString("Discover", comment: "")
            discoverHeader.setText(title, whiteWithShadow: !viewModel.isRootDiscoverView)
                        
            if let coverPath = self.viewModel.mainItem()?.cover, coverURL = NSURL(string: coverPath) {
                discoverHeader.backgroundImageView.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named: "auth_screen_bg_pattern"))
            } else {
                discoverHeader.backgroundImageView.image = UIImage(named: "auth_screen_bg_pattern")
            }
        }
        
        if let discoverShoutsHeader = header as? DiscoverShoutsHeaderView {
            if let discoverItem = viewModel.mainItem()?.title {
                discoverShoutsHeader.titleLabel.text = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), discoverItem)
            } else {
                discoverShoutsHeader.titleLabel.text = NSLocalizedString("Discover Shouts", comment: "")
            }
        }
        
        return header
    }
    
    // MARK: UICollectionView Flow Layout Delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return self.viewModel.headerSize(collectionView, section: section)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        return self.viewModel.footerSize(collectionView, section: section)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.viewModel.itemSize(indexPath, collectionView: collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return self.viewModel.minimumInteritemSpacingForSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return self.viewModel.insetsForSection(section)
    }

    // MARK: Actions
    func showDiscoverShouts() {
        guard let discoverItem = viewModel.mainItem() else {
            assertionFailure()
            return
        }
        self.flowDelegate?.showShoutsForDiscoverItem(discoverItem)
    }
}

extension DiscoverCollectionViewController : Bookmarking {
    
    func shoutForIndexPath(indexPath: NSIndexPath) -> Shout? {
        guard case .Shout(let shout) = self.viewModel.shoutItemsWithAds()[indexPath.item] else {
            return nil
        }
        
        return shout
    }
    
    func indexPathForShout(shout: Shout?) -> NSIndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        if let idx = self.viewModel.adManager.indexForItem(.Shout(shout: shout)) {
            return NSIndexPath(forItem: idx, inSection: 1)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(shout: Shout) {
        if let idx = self.viewModel.adManager.indexForItem(.Shout(shout: shout)) {
            self.viewModel.adManager.replaceItemAtIndex(idx, withItem: .Shout(shout: shout))
        }
        
    }
    
    @objc func switchBookmarkState(sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }
}
