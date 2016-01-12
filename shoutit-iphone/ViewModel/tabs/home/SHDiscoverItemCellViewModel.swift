//
//  SHDiscoverItemCellViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverItemCellViewModel: NSObject {

    private let cell: SHDiscoverItemCell
    private var discoverItem: SHDiscoverItem?
    
    init(cell: SHDiscoverItemCell) {
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
