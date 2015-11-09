//
//  SHDiscoverCellViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 09/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverCellViewModel: NSObject, SHCellViewModelProtocol {

    private let cell :SHDiscoverCollectionViewCell
    
    required init(cell: SHDiscoverCollectionViewCell) {
        self.cell = cell
    }
    
    func setup(item: SHDiscoverItem) {
        cell.textLabel.text = item.title
        if let imageUrl = item.image {
            loadImage(imageUrl)
        }
    }
    
    // MARK - Private
    private func loadImage(imageUrl: String) {
        if !imageUrl.isEmpty {
            cell.imageView.kf_setImageWithURL(NSURL(string: imageUrl)!, placeholderImage: UIImage(named: "image_placeholder"))
        }
    }
    
}
