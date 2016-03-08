//
//  EditProfileTextViewTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class EditProfileTextViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: BorderedMaterialTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.titleLabel = UILabel()
        textView.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textView.titleLabelColor = UIColor(shoutitColor: .DiscoverBorder)
        textView.titleLabelActiveColor = UIColor(shoutitColor: .TextFieldLightBlueColor)
    }
}
