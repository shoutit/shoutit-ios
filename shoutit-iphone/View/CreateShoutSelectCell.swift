//
//  CreateShoutSelectCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutSelectCell: UITableViewCell {
    @IBOutlet var selectButton : SelectButton!
 
    func fillWithFilter(filter: Filter, currentValue: FilterValue?) {
        self.selectButton.hideIcon = true
        
        if let _ = currentValue {
            self.selectButton.promptText = filter.name
        } else {
            self.selectButton.promptText = nil
        }
        
        if let value = currentValue {
            self.selectButton.setTitle(value.name, forState: .Normal)
        } else {
            self.selectButton.setTitle(filter.name, forState: .Normal)
        }
    }
}
