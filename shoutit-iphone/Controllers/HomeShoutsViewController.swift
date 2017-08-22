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
 
    let scrollOffset = Variable(CGPoint.zero)
    
    var reloadOnAppear = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = ShoutsCollectionViewModel(context: .homeShouts)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if reloadOnAppear {
            reloadOnAppear = false
            self.viewModel.reloadContent()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollOffset.value = scrollView.contentOffset
        
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.fetchNextPage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case .noContent = self.viewModel.pager.state.value {
            reloadOnAppear = true
            self.flowDelegate?.presentInterests()
            return
        }
        
        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}
