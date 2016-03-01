//
//  DiscoverCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class DiscoverCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var viewModel : DiscoverViewModel!
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerNibs()
        loadItems()
    }
    
    func registerNibs() {
        self.collectionView?.registerNib(UINib(nibName: "DiscoverHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.SubItems.headerIdentifier())
        self.collectionView?.registerNib(UINib(nibName: "DiscoverShoutsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.Shouts.headerIdentifier())
        self.collectionView?.registerNib(UINib(nibName: "DiscoverShoutFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: DiscoverSection.Shouts.footerIdentifier())
    }
    
    func loadItems() {
        if viewModel == nil {
            viewModel = DiscoverGeneralViewModel()
        }
        
        viewModel.items.asObservable().subscribeNext({ [weak self] (result) -> Void in
            self?.collectionView?.reloadSections(NSIndexSet(index: 0))
            }).addDisposableTo(disposeBag)
        
        viewModel.shouts.asObservable().subscribeNext({ [weak self] (result) -> Void in
            self?.collectionView?.reloadSections(NSIndexSet(index: 1))
            }).addDisposableTo(disposeBag)
        
        viewModel.retriveDiscoverItems()
    }
    
    // MARK: UICollectionView Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                _ = DiscoverFlowController(navigationController: self.navigationController!, discoverItem: element)
            }
            return
        }
        
        self.performSegueWithIdentifier("showSingleShout", sender: nil)
        
    }

    // MARK: UICollectionView Data Source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.discoverItems().count
        }
        
        return viewModel.shoutsItems().count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.viewModel.cellIdentifierForSection(indexPath.section), forIndexPath: indexPath)
    
        // Configure Shout cell
        if indexPath.section == 1 {
            if let element = self.viewModel?.shoutsItems()[indexPath.item] {
                let shoutCell = cell as! SHShoutItemCell
                shoutCell.bindWith(Shout: element)
            }
        }
        
        // Configure Discover cell
        if indexPath.section == 0 {
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                let discoverCell = cell as! SHShoutItemCell
                discoverCell.bindWith(DiscoverItem: element)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer =  collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.footerIdentifier(), forIndexPath: indexPath)
            
            if let discoverFooter = footer as? DiscoverShoutFooterView {
                discoverFooter.showShoutsButton.addTarget(self, action: "showDiscoverShouts", forControlEvents: .TouchUpInside)
            }
            
            return footer
        }
        
        let header =  collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.headerIdentifier(), forIndexPath: indexPath)
        
        if let discoverHeader = header as? DiscoverHeaderView {
            discoverHeader.titleLabel.text = self.viewModel.mainItem()?.title ?? NSLocalizedString("Discover", comment: "")
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
        if let navigationController = self.navigationController {
            _ = DiscoverShoutsFlowController(navigationController: navigationController, discoverItem: self.viewModel.mainItem())
        }
    }
}