//
//  PageCategoryCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class PageCategoryCell: UICollectionViewCell {
    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var iconImageView : UIImageView?

    func bindWithCategory(_ category: PageCategory) {
        self.titleLabel?.text = category.name
        
        if let iconPath = category.image {
            self.iconImageView?.sh_setImageWithURL(URL(string: iconPath), placeholderImage: nil)
        }
    }
}
