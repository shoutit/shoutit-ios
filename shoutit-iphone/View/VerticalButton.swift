//
//  VerticalButton.swift
//  shoutit
//
//  Created by Piotr Bernad on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class VerticalButton: UIButton {

    @IBInspectable var verticalAligmentPadding: CGFloat? = 6.0 {
        didSet {
            alignImageAndTitleVertically()
        }
    }

    func alignImageAndTitleVertically() {
        
        guard let verticalAligmentPadding = verticalAligmentPadding else {
            return
        }
        
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + verticalAligmentPadding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
    
}
