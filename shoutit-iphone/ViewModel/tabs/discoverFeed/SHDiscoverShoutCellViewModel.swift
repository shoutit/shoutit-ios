//
//  SHDiscoverShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutCellViewModel: NSObject {

    private let cell: SHDiscoverShoutCell
    private var shout: SHShout?
    
    init(cell: SHDiscoverShoutCell) {
        self.cell = cell
    }
    
    func setUp(viewController: UIViewController?, shout: SHShout) {
        self.shout = shout
        loadShoutImage(shout.thumbnail)
        cell.shouterName.text = shout.user?.name
        cell.shoutTitle.text = shout.title
        cell.shoutTitle.clipsToBounds = true
        cell.shouterName.clipsToBounds = true
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            cell.shoutPrice.text = price
            cell.shoutPrice.clipsToBounds = true
        }
    }
    
    // MARK - Private
    private func loadShoutImage(url: String?) {
        if let shoutThumbnailUrl = url, let nsUrl = NSURL(string: shoutThumbnailUrl) {
            cell.shoutImage.kf_setImageWithURL(nsUrl)
        }
    }
}
