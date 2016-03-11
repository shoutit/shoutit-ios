//
//  LabeledSelectButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LabeledSelectButton: RightArrowSelectButton {
    
    var smallTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        smallTitleLabel = UILabel()
        smallTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        smallTitleLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Regular)
        smallTitleLabel.textColor = UIColor(shoutitColor: .DiscoverBorder)
        addSubview(smallTitleLabel)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[l]", options: [], metrics: nil, views: ["l" : smallTitleLabel]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[l]", options: [], metrics: nil, views: ["l" : smallTitleLabel]))
    }
    
//    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
//        return CGRect(x: 36, y: 15, width: contentRect.width - 36, height: contentRect.height - 15)
//    }
//    
//    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
//        return CGRect(x: 10, y: 22, width: 18, height: 18)
//    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRect(x: 10, y: 15, width: contentRect.width - 10, height: contentRect.height - 15)
    }
}
