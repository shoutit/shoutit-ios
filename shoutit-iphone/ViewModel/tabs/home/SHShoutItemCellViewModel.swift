//
//  SHShoutItemCellViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutItemCellViewModel: NSObject {

    private let cell: SHShoutItemCell
    private var shout: SHShout?
    
    init(cell: SHShoutItemCell) {
        self.cell = cell
    }
    
    func setUp(viewController: UIViewController?, shout: SHShout) {
        self.shout = shout
        loadShoutImage(shout.thumbnail)
        cell.name.text = shout.user?.name
        cell.shoutTitle.text = shout.title
        cell.shoutType?.layer.borderWidth = 0.8
        cell.shoutType?.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_BORDER_DISCOVER)?.CGColor
        cell.shoutType?.layer.cornerRadius = 2
    }
    
    // MARK - Private
    private func loadShoutImage(url: String?) {
        if let shoutThumbnailUrl = url, let nsUrl = NSURL(string: shoutThumbnailUrl) {
            cell.shoutImage.kf_setImageWithURL(nsUrl)
        }
    }
    
}
