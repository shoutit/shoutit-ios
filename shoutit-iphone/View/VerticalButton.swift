//
//  VerticalButton.swift
//  shoutit
//
//  Created by Piotr Bernad on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class VerticalButton: UIButton {
    
    let bottomMargin : CGFloat = 5.0
    let titleHeight : CGFloat = 30.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView?.contentMode = .Center
        self.titleLabel?.textAlignment = .Center
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: contentRect.size.height - titleHeight - bottomMargin, width: contentRect.size.width, height: titleHeight)
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: contentRect.size.width, height: contentRect.size.height - titleHeight)
    }
}
