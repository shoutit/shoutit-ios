//
//  SearchSuggestionTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SearchSuggestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leadingImageView: UIImageView!
    @IBOutlet weak var trailingImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
    
    func showLeadingImageView(show: Bool) {
        leadingImageView.hidden = !show
        labelLeadingConstraint.constant = show ? 50 : 10
    }
}
