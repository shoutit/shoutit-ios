//
//  FormTextField.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

final class FormTextField: BorderedMaterialTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.font = UIFont.systemFontOfSize(18.0)
        self.textColor = MaterialColor.black
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        self.titleLabelColor = MaterialColor.grey.lighten1
        self.titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        self.clearButtonMode = .WhileEditing
        
        self.detailLabel = UILabel()
        self.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        self.detailLabelActiveColor = MaterialColor.red.accent3
        
        self.backgroundColor = UIColor.clearColor()
    }
}
