//
//  SelectButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SelectButton: UIButton {

    @IBInspectable var promptText : String?

    private var promptLabel : UILabel!
    private var selectImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        promptLabel = UILabel()
        promptLabel.text = promptText
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.backgroundColor = UIColor.clearColor()
        promptLabel.font = UIFont.systemFontOfSize(12.0)
        promptLabel.textColor = UIColor.lightGrayColor()
        self.addSubview(promptLabel)
        
        self.addConstraints([NSLayoutConstraint(item: promptLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10),
                            NSLayoutConstraint(item: promptLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 5)])
        
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.contentVerticalAlignment = .Bottom
        self.contentHorizontalAlignment = .Left
        
        self.selectImageView = UIImageView(image: UIImage(named: "down_thin"))
        self.selectImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.selectImageView)
        
        self.selectImageView.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0),
                                             NSLayoutConstraint(item: selectImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)])
        self.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10),
                            NSLayoutConstraint(item: selectImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        
    }
    
    override func contentRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 5)
    }
    
}
