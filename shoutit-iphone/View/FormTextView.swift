//
//  FormTextView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class FormTextView: BorderedMaterialTextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholderLabel = UILabel()
        placeholderLabel!.font = UIFont.sh_systemFontOfSize(18, weight: .regular)
        placeholderLabel!.textColor = UIColor(shoutitColor: .discoverBorder)
        
        titleLabel = UILabel()
        titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .medium)
        titleLabelColor = UIColor(shoutitColor: .discoverBorder)
        titleLabelActiveColor = UIColor(shoutitColor: .shoutitLightBlueColor)
        
        detailLabel = UILabel()
        detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .medium)
        detailLabelActiveColor = UIColor(shoutitColor: .discoverBorder)
        detailLabelHidden = false
    }
}
