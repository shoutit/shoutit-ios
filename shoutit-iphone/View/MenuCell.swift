//
//  MenuCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindWith(item: NavigationItem!) {
        self.iconImageView?.image = NavigationItem.icon(item)()
        self.titleLabel.text = NavigationItem.title(item)()
    }
}
