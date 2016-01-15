//
//  SHDiscoverShoutsCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/15/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutsCell: UICollectionViewCell {
    
    private var viewModel: SHDiscoverShoutsCellViewModel?
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = SHDiscoverShoutsCellViewModel(cell: self)
    }
    
    func setUp(viewController: UIViewController?, shout: SHShout) {
        viewModel?.setUp(viewController, shout: shout)
    }
}
