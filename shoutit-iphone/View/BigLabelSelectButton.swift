//
//  FilterRightArrowButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class BigLabelSelectButton: SelectButton {
    
    var bigTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.font = UIFont.systemFontOfSize(12.0)
        
        bigTitleLabel = UILabel()
        bigTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bigTitleLabel.font = UIFont.sh_systemFontOfSize(18, weight: .Regular)
        bigTitleLabel.textColor = UIColor(shoutitColor: .ShoutitBlack)
        addSubview(bigTitleLabel)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[l]", options: [], metrics: nil, views: ["l" : bigTitleLabel]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-7-[l]", options: [], metrics: nil, views: ["l" : bigTitleLabel]))
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRect(x: 10, y: 29, width: contentRect.width - 10, height: contentRect.height - 29)
    }
}
