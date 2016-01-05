//
//  SHShoutDiscoverTitleCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutDiscoverTitleCell: UICollectionViewCell {
    @IBOutlet weak var discoverLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let location = SHAddress.getUserOrDeviceLocation() {
            discoverLabel.text = "DISCOVER" + " " + "\(location.city.uppercaseString)"
        }
    }
}
