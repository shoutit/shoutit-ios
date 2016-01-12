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
    @IBOutlet weak var selectCategoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = SHPostSignupCategoriesCellViewModel(cell: self)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUp(category: String) {
        viewModel?.setUp(category)
    }
    
    @IBAction func selectCategoryAction(sender: AnyObject) {
        if (selectCategoryButton.currentBackgroundImage == UIImage(named: "checkbox")) {
            selectCategoryButton.setBackgroundImage(UIImage(named: "checkboxChecked"), forState: .Normal)
        }
    }
    

}
