//
//  ShoutDetailBackgroundSwappableTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutDetailBackgroundSwappableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var internalContentView: UIView!
    
    func setBackgroundForRow(row: Int) {
        let isEven = row % 2 == 0
        internalContentView.backgroundColor = isEven ? UIColor.whiteColor() : UIColor.clearColor()
    }
}