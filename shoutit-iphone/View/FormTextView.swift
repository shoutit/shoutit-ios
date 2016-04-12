//
//  FormTextView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class FormTextView: BorderedMaterialTextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholderLabel = UILabel()
        placeholderLabel!.font = UIFont.sh_systemFontOfSize(18, weight: .Regular)
        placeholderLabel!.textColor = UIColor(shoutitColor: .DiscoverBorder)
        
        titleLabel = UILabel()
        titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        titleLabelColor = UIColor(shoutitColor: .DiscoverBorder)
        titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        
        detailLabel = UILabel()
        detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        detailLabelActiveColor = UIColor(shoutitColor: .DiscoverBorder)
        detailLabelHidden = false
    }
}
