//
//  LocationChoiceTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LocationChoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: SelectionButton!
}

extension LocationChoiceTableViewCell: ReusableView {}
