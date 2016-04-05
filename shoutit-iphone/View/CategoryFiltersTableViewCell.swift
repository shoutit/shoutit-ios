//
//  CategoryFiltersTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CategoryFiltersTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkboxImageView.image = selected ? UIImage.filtersCheckboxSelected() : UIImage.filtersCheckbox()
    }
}
