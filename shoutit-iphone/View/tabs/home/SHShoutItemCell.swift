//
//  SHShoutItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutItemCell: UICollectionViewCell {
    
    private var viewModel: SHShoutItemCellViewModel?
    @IBOutlet weak var shoutImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shoutTitle: UILabel!
    @IBOutlet weak var shoutPrice: UILabel!
    @IBOutlet weak var shoutType: UILabel?
    @IBOutlet weak var shoutTimeAgo: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHShoutItemCellViewModel(cell: self)
    }
    
    func setUp(viewController: UIViewController?, shout: SHShout) {
        viewModel?.setUp(viewController, shout: shout)
    }
    
}
