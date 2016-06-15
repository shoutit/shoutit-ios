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
import ShoutitKit

class HomeShoutsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var viewModel = HomeShoutsViewModel()
    let scrollOffset = Variable(CGPointZero)
    let disposeBag = DisposeBag()
    let selectionDisposeBag = DisposeBag()
    let refreshControl = UIRefreshControl()
    private var numberOfReloads = 0
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    private let retry = Variable(false)
    
    var selectedItem = BehaviorSubject<Shout?>(value: nil)
    
    var items : [Shout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplayable()
        setupDataSource()

        refreshControl.addTarget(self, action: #selector(HomeShoutsCollectionViewController.forceReloadData), forControlEvents: .ValueChanged)
        self.collectionView?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.refreshControl.endRefreshing()
    }
    
    func reloadData() {
        retry.value = false
    }
    
    func forceReloadData() {
        retry.value = true
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
    
    private func setupDisplayable() {
        viewModel.displayable.applyOnLayout(self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)
        
        viewModel.displayable.contentOffset.asObservable().subscribeNext {[weak self] (offset) -> Void in
            self?.scrollOffset.value = offset
        }.addDisposableTo(disposeBag)
        
        viewModel.displayable.selectedIndexPath.asObservable().subscribeNext { [weak self] (indexPath) -> Void in
            if let selectedIndexPath = indexPath, element = self?.items[selectedIndexPath.item] {
                self?.selectedItem.on(.Next(element))
            }
        }.addDisposableTo(selectionDisposeBag)
    }
    
    private func setupDataSource() {
        
        if let collection = self.collectionView {
            
            let userObservable = Observable.combineLatest(retry.asObservable(), Account.sharedInstance.userSubject) {$0}
            userObservable
                .filter({ (reload, user) -> Bool in
                    return user != nil
                })
                .distinctUntilChanged {(lhs, rhs) -> Bool in
                    let oldUser = lhs.1
                    let newUser = rhs.1
                    let forceReload = rhs.0
                    return oldUser?.id == newUser?.id && oldUser?.location.address == newUser?.location.address && !forceReload
                }
                .flatMap{ [weak self] (reload) -> Observable<[Shout]> in
                    return (self?.viewModel.retriveShouts())!
                }
                .subscribeNext{ [weak self] (shouts) -> Void in
                    self?.items = shouts
                    self?.collectionView?.reloadData()
                    self?.refreshControl.endRefreshing()
                }
                .addDisposableTo(disposeBag)
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            collection.emptyDataSetDelegate = self
            collection.emptyDataSetSource = self
        }
        
        viewModel.dataSubject.subscribeNext({ [weak self] (shouts) -> Void in
            
            shouts.each({ (shout) -> () in
                self?.items.append(shout)
            })
            
            if let itms = self?.items {
                self?.items = itms.unique()
            }
            
            self?.collectionView?.reloadData()
        }).addDisposableTo(disposeBag)
        
        viewModel.loading.asDriver().driveNext {[weak self] (loading) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self?.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: loading ? 50.0 : 0, right: 0)
            })
            
            if loading {
                self?.showActivityIndicatorView()
                self?.layoutActivityIndicatorView()
            } else {
                self?.hideActivityIndicatorView()
            }
            
        }.addDisposableTo(disposeBag)
    }
    
    private func showActivityIndicatorView() {
        collectionView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func layoutActivityIndicatorView() {
        if let collectionView = collectionView {
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
            activityIndicator.center = CGPoint(x: collectionView.center.x, y: collectionView.contentSize.height + 30.0)
        }
    }
    
    private func hideActivityIndicatorView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
