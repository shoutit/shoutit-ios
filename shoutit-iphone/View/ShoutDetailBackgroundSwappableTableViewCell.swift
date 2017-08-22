//
//  ShoutDetailBackgroundSwappableTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutDetailBackgroundSwappableTableViewCell: UITableViewCell, Borderable {
    
    @IBOutlet weak var internalContentView: BorderedView!
    
    func setBackgroundForRow(_ row: Int) {
        let isEven = row % 2 == 0
        internalContentView.backgroundColor = isEven ? UIColor.white : UIColor(shoutitColor: .cellBackgroundGrayColor)
    }
}
