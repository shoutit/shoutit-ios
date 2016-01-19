//
//  SHDiscoverShoutListCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutListCell: UICollectionViewCell {

    private var viewModel: SHDiscoverShoutListCellViewModel?
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shouterName: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var shoutType: UILabel!
    
    @IBOutlet weak var trailingSpaceToCategory: NSLayoutConstraint!
    @IBOutlet weak var trailingSpaceToChat: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = SHDiscoverShoutListCellViewModel(cell: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trailingSpaceToCategory.constant = UIScreen.mainScreen().bounds.width / 16.136
        trailingSpaceToChat.constant = UIScreen.mainScreen().bounds.width / 14.791
    }
    
    func setUp(viewController: UIViewController?, shout: SHShout) {
        viewModel?.setUp(viewController, shout: shout)
    }

}
