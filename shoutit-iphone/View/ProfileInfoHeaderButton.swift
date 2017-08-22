//
//  ProfileInfoHeaderButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ProfileInfoHeaderButton: UIButton {
    
    // UI
    var mainLabel: UILabel?
    var iconImageView: UIImageView?
    var countLabel: UILabel?
    
    func setTitleText(_ text: String) {
        
        if let mainLabel = mainLabel {
            mainLabel.text = text
            return
        }
        
        mainLabel = UILabel()
        mainLabel?.translatesAutoresizingMaskIntoConstraints = false
        mainLabel?.font = UIFont.systemFont(ofSize: 14)
        mainLabel?.textColor = UIColor(shoutitColor: .fontGrayColor)
        mainLabel?.text = text
        addSubview(mainLabel!)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: mainLabel!, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: mainLabel!, attribute: .top, multiplier: 1.0, constant: -5.0))
    }
    
    func setImage(_ image: UIImage, countText: String?) {
        
        if let iconImageView = iconImageView {
            iconImageView.image = image
            countLabel?.text = countText
            return
        }
        
        iconImageView = UIImageView()
        iconImageView?.contentMode = .center
        iconImageView?.translatesAutoresizingMaskIntoConstraints = false
        iconImageView?.image = image
        addSubview(iconImageView!)
        
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28.0))
        iconImageView?.addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 28.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: iconImageView!, attribute: .bottom, multiplier: 1.0, constant: -2.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: iconImageView!, attribute: .centerX, multiplier: 1.0, constant: countText == nil ? 0 : 8))
        
        guard let countText = countText else {
            return
        }
        
        if let countLabel = countLabel {
            countLabel.text = countText
            return
        }
        
        countLabel = UILabel()
        countLabel?.translatesAutoresizingMaskIntoConstraints = false
        countLabel?.font = UIFont.systemFont(ofSize: 14)
        countLabel?.textColor = UIColor(shoutitColor: .fontGrayColor)
        countLabel?.text = countText
        addSubview(countLabel!)
        
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .trailing, relatedBy: .equal, toItem: countLabel!, attribute: .leading, multiplier: 1.0, constant: -5.0))
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .centerY, relatedBy: .equal, toItem: countLabel!, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
}
