//
//  SHDiscoverShoutsHeaderCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutsHeaderCell: UICollectionViewCell {
    @IBOutlet weak var shoutViewType: UIButton!
    
    var viewModel: SHDiscoverShoutsHeaderCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = SHDiscoverShoutsHeaderCellViewModel(cell: self)
    }
    
    func setUp(viewController: SHDiscoverShoutsViewController) {
        viewModel?.setUp(viewController)
    }
    
    @IBAction func shoutViewTypeAction(sender: AnyObject) {
       viewModel?.toggleSwitchView() 
    }
    
}
