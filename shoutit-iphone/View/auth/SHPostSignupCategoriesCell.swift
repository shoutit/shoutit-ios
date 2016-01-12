//
//  SHPostSignupCategoriesCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/12/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHPostSignupCategoriesCell: UITableViewCell {

    private var viewModel: SHPostSignupCategoriesCellViewModel?
    
    @IBOutlet weak var categoryTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    

}
