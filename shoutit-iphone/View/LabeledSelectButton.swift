//
//  LabeledSelectButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LabeledSelectButton: SelectButton {
    
    var smallTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        smallTitleLabel = UILabel()
        smallTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        smallTitleLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Regular)
        smallTitleLabel.textColor = UIColor(shoutitColor: .DiscoverBorder)
        addSubview(smallTitleLabel)
        
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[l]-10-|", options: [], metrics: nil, views: ["l" : smallTitleLabel]))
        } else {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[l]", options: [], metrics: nil, views: ["l" : smallTitleLabel]))
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[l]", options: [], metrics: nil, views: ["l" : smallTitleLabel]))
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRect(x: contentRect.minX + 10, y: 15, width: contentRect.width - 10, height: contentRect.height - 15)
    }
}
