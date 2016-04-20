//
//  SettingsTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class SettingsTableViewCell: UITableViewCell {
    
    // views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    // constraints
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorMarginConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disclosureIndicatorImageView.image = UIImage.rightBlueArrowDisclosureIndicator()
    }
}
