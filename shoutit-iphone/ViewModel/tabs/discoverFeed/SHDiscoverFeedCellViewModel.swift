//
//  SHDiscoverFeedCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/7/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedCellViewModel: NSObject {

    private let cell: SHDiscoverFeedCell
    private var discoverItem: SHDiscoverItem?
    
    init(cell: SHDiscoverFeedCell) {
        self.cell = cell
    }
    
    func setUp(viewController: UIViewController?, discoverItem: SHDiscoverItem) {
        self.discoverItem = discoverItem
        
        cell.discoverTitle.text = discoverItem.title
        loadDiscoverImage(discoverItem.image)
    }
    
    // MARK - Private
    private func loadDiscoverImage(url: String?) {
        if let discoverUrl = url, let nsUrl = NSURL(string: discoverUrl) {
            cell.discoverImage.kf_setImageWithURL(nsUrl)
        }
    }
}
