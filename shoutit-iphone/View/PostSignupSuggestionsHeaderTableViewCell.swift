//
//  PostSignupSuggestionsHeaderTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class PostSignupSuggestionsHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorViewHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
    }
}