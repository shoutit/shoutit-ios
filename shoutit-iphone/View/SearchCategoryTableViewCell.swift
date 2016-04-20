//
//  SearchCategoryTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class SearchCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
        disclosureIndicatorImageView.image = UIImage.rightBlueArrowDisclosureIndicator()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
    
    func setConstraintForPosition(isLast last: Bool) {
        separatorLeadingConstraint.constant = last ? 0 : 80
    }
}
