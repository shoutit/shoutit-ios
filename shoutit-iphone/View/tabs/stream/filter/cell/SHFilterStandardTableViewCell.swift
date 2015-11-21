//
//  SHFilterStandardTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHFilterStandardTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
