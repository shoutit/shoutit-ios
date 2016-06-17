//
//  PromotionOptionTableViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class PromotionOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var labelText: UILabel?
    @IBOutlet weak var labelBackground: UIView?
    @IBOutlet weak var daysLabel: UILabel?
    @IBOutlet weak var creditsLabel: UILabel?
    @IBOutlet weak var daysLabelBackground: UIView?
  
    func bindWithOption(option: PromotionOption) {
        self.nameLabel?.text = option.name
        self.labelText?.text = option.label.name
        self.labelBackground?.backgroundColor = option.label.color()
        
        if let days = option.days {
            self.daysLabel?.text = "\(days) \(NSLocalizedString("days", comment: ""))"
            self.daysLabel?.hidden = false
            self.daysLabelBackground?.hidden = false
        } else {
            self.daysLabel?.hidden = true
            self.daysLabelBackground?.hidden = true
        }
        self.creditsLabel?.text = "\(option.credits) \(NSLocalizedString("Credits", comment: ""))"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
    }
}
