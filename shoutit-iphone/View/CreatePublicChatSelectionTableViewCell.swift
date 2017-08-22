//
//  CreatePublicChatSelectionTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreatePublicChatSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tickImageView.isHidden = !selected
    }
}

extension CreatePublicChatSelectionTableViewCell: ReusableView {}
