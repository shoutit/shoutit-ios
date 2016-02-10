//
//  PostSignupSuggestionsHeaderTableViewCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class PostSignupSuggestionsHeaderTableViewCell: UITableViewCell {
    
    var roundedTop = true
    var roundedBottom = false
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if roundedTop && roundedBottom {
            layer.cornerRadius = 22;
            layer.masksToBounds = true;
            return;
            
        }
        
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let size = CGSize(width: 22, height: 22)
        
        if roundedTop {
            shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: size).CGPath
            layer.mask = shape;
            layer.masksToBounds = true;
            return;
        }
        
        if roundedBottom {
            shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: size).CGPath
            layer.mask = shape;
            layer.masksToBounds = true;
        }
    }
}