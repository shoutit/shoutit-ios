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
    
    func setImage(image: UIImage) {
        
        if let iconImageView = iconImageView {
            iconImageView.image = image
        }
        
        iconImageView = UIImageView()
        iconImageView?.translatesAutoresizingMaskIntoConstraints = false
        iconImageView?.image = image
        addSubview(iconImageView!)
        
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 28.0))
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 28.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: iconImageView!, attribute: .Bottom, multiplier: 1.0, constant: -5.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: iconImageView!, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func setCountText(text: String) {
        
        if let countLabel = countLabel {
            countLabel.text = text
            return
        }
        
        countLabel = UILabel()
        countLabel?.translatesAutoresizingMaskIntoConstraints = false
        countLabel?.font = UIFont.systemFontOfSize(14)
        countLabel?.textColor = UIColor(shoutitColor: .FontGrayColor)
        countLabel?.text = text
        addSubview(countLabel!)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: countLabel!, attribute: .Leading, multiplier: 1.0, constant: -7.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: countLabel!, attribute: .Bottom, multiplier: 1.0, constant: 1.0))
    }
}
