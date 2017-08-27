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
            self.collectionView?.reloadItems(at: indexPaths)
        }
        
        self.viewModel.adManager.shoutsSection = 1
    }
    
    func registerNibs() {
        self.collectionView?.register(UINib(nibName: "DiscoverHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.subItems.headerIdentifier())
        self.collectionView?.register(UINib(nibName: "DiscoverShoutsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.shouts.headerIdentifier())
        self.collectionView?.register(UINib(nibName: "DiscoverShoutFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: DiscoverSection.shouts.footerIdentifier())
        self.collectionView?.register(UINib(nibName: "ShoutsExpandedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShoutsExpandedCollectionViewCell")
    }
    
    func loadItems() {
        if viewModel == nil {
            viewModel = DiscoverGeneralViewModel()
        }
        
        viewModel.items.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (result) in
            self?.collectionView?.reloadData()
        }).addDisposableTo(disposeBag)
        
        viewModel.shouts.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (result) in
            self?.collectionView?.reloadData()
        }).addDisposableTo(disposeBag)
        
        viewModel.retriveDiscoverItems()
        
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction(_ sender: AnyObject) {
        if let discoverItem = viewModel.mainItem() {
            flowDelegate?.showSearchInContext(.discoverShouts(item: discoverItem))
        } else {
            flowDelegate?.showSearchInContext(.general)
        }
    }
    
    // MARK: UICollectionView Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                flowDelegate?.showDiscoverForDiscoverItem(element)
            }
            return
        }
        
        if case .shout(let shout) = self.viewModel.shoutItemsWithAds()[indexPath.item] {
            flowDelegate?.showShout(shout)
        }
    }

    // MARK: UICollectionView Data Source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.discoverItems().count
        }
        
        return viewModel.shoutItemsWithAds().count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.cellIdentifierForIndexPath(indexPath), for: indexPath)
    
        
        // Configure Shout cell
        if indexPath.section == 1 {
            if case .shout(let element) = self.viewModel.shoutItemsWithAds()[indexPath.item] {
                let shoutCell = cell as! ShoutsCollectionViewCell
                shoutCell.bindWith(Shout: element)
                shoutCell.bookmarkButton?.tag = indexPath.item
                shoutCell.bookmarkButton?.addTarget(self, action: #selector(switchBookmarkState), for: .touchUpInside)
            }

            return cell
        }
        
        // Configure Discover cell
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.viewModel.cellIdentifierForIndexPath(indexPath), for: indexPath)
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                let discoverCell = cell as! ShoutsCollectionViewCell
                discoverCell.bindWith(DiscoverItem: element)
            }
            
            return cell
        }
        
        fatalError("Not supported section")
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.footerIdentifier(), for: indexPath)
            
            if let discoverFooter = footer as? DiscoverShoutFooterView {
                discoverFooter.showShoutsButton.addTarget(self, action: #selector(DiscoverCollectionViewController.showDiscoverShouts), for: .touchUpInside)
            }
            
            return footer
        }
        
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.headerIdentifier(), for: indexPath)
        
        
        if let discoverHeader = header as? DiscoverHeaderView {
            let title = viewModel.mainItem()?.title ?? NSLocalizedString("Discover", comment: "Discover Header")
            discoverHeader.setText(title, whiteWithShadow: !viewModel.isRootDiscoverView)
                        
            if let coverPath = self.viewModel.mainItem()?.cover, let coverURL = URL(string: coverPath) {
                discoverHeader.backgroundImageView.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named: "auth_screen_bg_pattern"))
            } else {
                discoverHeader.backgroundImageView.image = UIImage(named: "auth_screen_bg_pattern")
            }
        }
        
        if let discoverShoutsHeader = header as? DiscoverShoutsHeaderView {
            if let discoverItem = viewModel.mainItem()?.title {
                discoverShoutsHeader.titleLabel.text = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Number of discover Shouts"), discoverItem)
            } else {
                discoverShoutsHeader.titleLabel.text = NSLocalizedString("Discover Shouts", comment: "Discover Shouts Title Placeholder")
            }
        }
        
        return header
    }
    
    // MARK: UICollectionView Flow Layout Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return self.viewModel.headerSize(collectionView, section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        return self.viewModel.footerSize(collectionView, section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.viewModel.itemSize(indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.viewModel.minimumInteritemSpacingForSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
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
    
    func shoutForIndexPath(_ indexPath: IndexPath) -> Shout? {
        guard case .shout(let shout) = self.viewModel.shoutItemsWithAds()[indexPath.item] else {
            return nil
        }
        
        return shout
    }
    
    func indexPathForShout(_ shout: Shout?) -> IndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        if let idx = self.viewModel.adManager.indexForItem(.shout(shout: shout)) {
            return IndexPath(item: idx, section: 1)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(_ shout: Shout) {
        if let idx = self.viewModel.adManager.indexForItem(.shout(shout: shout)) {
            self.viewModel.adManager.replaceItemAtIndex(idx, withItem: .shout(shout: shout))
        }
        
    }
    
    @objc func switchBookmarkState(_ sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }
}
