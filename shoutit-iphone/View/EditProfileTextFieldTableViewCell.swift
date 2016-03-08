//
//  EditProfileTextFieldTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class EditProfileTextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: BorderedMaterialTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.titleLabel = UILabel()
        textField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        textField.titleLabelColor = UIColor(shoutitColor: .DiscoverBorder)
        textField.titleLabelActiveColor = UIColor(shoutitColor: .TextFieldLightBlueColor)
        textField.clearButtonMode = .WhileEditing
    }
}
