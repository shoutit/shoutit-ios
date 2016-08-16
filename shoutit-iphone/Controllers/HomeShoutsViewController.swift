//
//  HomeShoutsViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 03/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import DZNEmptyDataSet
import ShoutitKit

class HomeShoutsViewController : ShoutsCollectionViewController {
 
    let scrollOffset = Variable(CGPointZero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = ShoutsCollectionViewModel(context: .HomeShouts)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Account.sharedInstance.userSubject.distinctUntilChanged {(oldUser, newUser) -> Bool in
            return oldUser?.id == newUser?.id && oldUser?.location.address == newUser?.location.address
        }
        .skip(1)
        .subscribeNext { [weak self] (user) in
                self?.viewModel.reloadContent()
        }.addDisposableTo(disposeBag)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollOffset.value = scrollView.contentOffset
        
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.fetchNextPage()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if case .NoContent = self.viewModel.pager.state.value {
            showInterests()
            return
        }
        
        super.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
    }
    
    func showInterests() {
        print("show interests")
    }
}