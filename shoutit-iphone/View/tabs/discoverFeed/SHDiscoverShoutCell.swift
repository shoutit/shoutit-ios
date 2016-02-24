//
//  SHDiscoverShoutCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutCell: UICollectionViewCell {

    private var viewModel: SHDiscoverShoutCellViewModel?
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shouterName: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHDiscoverShoutCellViewModel(cell: self)
    }

    func setUp(viewController: UIViewController?, shout: SHShout) {
        viewModel?.setUp(viewController, shout: shout)
    }
    
}
