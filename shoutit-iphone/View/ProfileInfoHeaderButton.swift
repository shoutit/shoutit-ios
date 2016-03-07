//
//  ProfileInfoHeaderButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileInfoHeaderButton: UIButton {
    
    // UI
    var mainLabel: UILabel?
    var iconImageView: UIImageView?
    var countLabel: UILabel?
    
    func setTitleText(text: String) {
        
        if let mainLabel = mainLabel {
            mainLabel.text = text
            return
        }
        
        mainLabel = UILabel()
        mainLabel?.translatesAutoresizingMaskIntoConstraints = false
        mainLabel?.font = UIFont.systemFontOfSize(14)
        mainLabel?.textColor = UIColor(shoutitColor: .FontGrayColor)
        mainLabel?.text = text
        addSubview(mainLabel!)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: mainLabel!, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: mainLabel!, attribute: .Top, multiplier: 1.0, constant: -5.0))
    }
    
    func setImage(image: UIImage, countText: String?) {
        
        if let iconImageView = iconImageView {
            iconImageView.image = image
            countLabel?.text = countText
            return
        }
        
        iconImageView = UIImageView()
        iconImageView?.translatesAutoresizingMaskIntoConstraints = false
        iconImageView?.image = image
        addSubview(iconImageView!)
        
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 28.0))
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 28.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: iconImageView!, attribute: .Bottom, multiplier: 1.0, constant: -2.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: iconImageView!, attribute: .CenterX, multiplier: 1.0, constant: countText == nil ? 0 : 8))
        
        guard let countText = countText else {
            return
        }
        
        if let countLabel = countLabel {
            countLabel.text = countText
            return
        }
        
        countLabel = UILabel()
        countLabel?.translatesAutoresizingMaskIntoConstraints = false
        countLabel?.font = UIFont.systemFontOfSize(14)
        countLabel?.textColor = UIColor(shoutitColor: .FontGrayColor)
        countLabel?.text = countText
        addSubview(countLabel!)
        
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .Trailing, relatedBy: .Equal, toItem: countLabel!, attribute: .Leading, multiplier: 1.0, constant: -5.0))
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .CenterY, relatedBy: .Equal, toItem: countLabel!, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
    }
}
