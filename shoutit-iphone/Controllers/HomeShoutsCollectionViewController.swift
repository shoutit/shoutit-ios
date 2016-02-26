//
//  HomeShoutsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import DZNEmptyDataSet

class HomeShoutsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var viewModel = HomeShoutsViewModel()
    let scrollOffset = Variable(CGPointZero)
    let disposeBag = DisposeBag()
    let selectionDisposeBag = DisposeBag()
    
    var retry = Variable(true)
    
    var selectedItem = BehaviorSubject<Shout?>(value: nil)
    
    var items : [Shout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplayable()
        setupDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        retry.value = false
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath) as! SHShoutItemCell
    
        let element = items[indexPath.item]
        
        cell.bindWith(Shout: element)
            
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let element = items[indexPath.item]
        self.selectedItem.on(.Next(element))
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: Empty Data Set
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No shouts available", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(20)])
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: Actions
    
    func changeCollectionViewDisplayMode(sender: UIButton) {
        sender.selected = viewModel.changeDisplayModel() == ShoutsLayout.VerticalList
        
        setupDisplayable()
    }
    
    func setupDisplayable() {
        viewModel.displayable.applyOnLayout(self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)
        
        viewModel.displayable.contentOffset.asObservable().subscribeNext { (offset) -> Void in
            self.scrollOffset.value = offset
        }.addDisposableTo(disposeBag)
        
        viewModel.displayable.selectedIndexPath.asObservable().subscribeNext { [weak self] (indexPath) -> Void in
            if let selectedIndexPath = indexPath, element = self?.items[selectedIndexPath.item] {
                self?.selectedItem.on(.Next(element))
            }
        }.addDisposableTo(selectionDisposeBag)
    }
    
    func setupDataSource() {
        if let collection = self.collectionView {
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            let retryObservable = retry.asObservable().filter{$0}
            let userChangeObservable = Account.sharedInstance.userSubject
            let combined = Observable.combineLatest(retryObservable, userChangeObservable) { (_, _) -> Void in}
            
            combined
                .flatMap({ [weak self] (reload) -> Observable<[Shout]> in
                    return (self?.viewModel.retriveShouts())!
                    })
                .subscribeNext({ [weak self] (shouts) -> Void in
                    self?.items = shouts
                    self?.collectionView?.reloadData()
                })
                .addDisposableTo(disposeBag)
            
            collection.emptyDataSetDelegate = self
            collection.emptyDataSetSource = self
        }
        
        viewModel.dataSubject?.subscribeNext({ [weak self] (shouts) -> Void in
            
            shouts.each({ (shout) -> () in
                self?.items.append(shout)
            })
            
            if let itms = self?.items {
                self?.items = itms.unique()
            }
            
            self?.collectionView?.reloadData()
        }).addDisposableTo(disposeBag)
    }
}
