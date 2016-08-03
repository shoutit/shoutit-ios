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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollOffset.value = scrollView.contentOffset
        
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.fetchNextPage()
        }
    }
}