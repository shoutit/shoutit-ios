//
//  SelectButton.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

class SelectButton: UIButton {

    @IBInspectable var promptText : String?

    private var promptLabel : UILabel!
    private var selectImageView : UIImageView!
    private var activityIndicatorView : UIActivityIndicatorView?
    
    var optionsLoaded = true {
        didSet {
            self.titleLabel?.alpha = optionsLoaded ? 1.0 : 0.0
            setActivityIndicatorVisible(!optionsLoaded)
            self.userInteractionEnabled = optionsLoaded
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        self.titleLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        
        promptLabel = UILabel()
        promptLabel.text = promptText
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.backgroundColor = UIColor.clearColor()
        promptLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        promptLabel.textColor = MaterialColor.grey.lighten1
        self.addSubview(promptLabel)
        
        self.addConstraints([NSLayoutConstraint(item: promptLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 9),
                            NSLayoutConstraint(item: promptLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 5)])
        
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = MaterialColor.grey.lighten1.CGColor
        
        self.contentHorizontalAlignment = .Left
        
        if self.promptAvailable() {
            self.contentVerticalAlignment = .Bottom
        } else {
            self.contentVerticalAlignment = .Center
        }
        
        self.selectImageView = UIImageView(image: selectImage())
        self.selectImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.selectImageView)
        
        self.selectImageView.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0),
                                             NSLayoutConstraint(item: selectImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)])
        self.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10),
                            NSLayoutConstraint(item: selectImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        activityIndicator.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0),
                                          NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)])
        self.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -9),
                             NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        self.activityIndicatorView = activityIndicator
        
        
    }
    
    override func contentRectForBounds(bounds: CGRect) -> CGRect {
        if self.promptAvailable() {
            return CGRectInset(bounds, 10, 5)
        }
        
        return CGRectInset(bounds, 10, 0)
    }
    
    func promptAvailable() -> Bool {
        return self.promptText?.characters.count > 0
    }
    
    func setActivityIndicatorVisible(value: Bool) {
        if value {
            addActivityIndicator()
        } else {
            removeActivityIndicator()
        }
    }
    
    func removeActivityIndicator() {
        self.activityIndicatorView?.hidden = true
        self.activityIndicatorView?.stopAnimating()
    }
    
    func addActivityIndicator() {
        self.activityIndicatorView?.hidden = false
        self.activityIndicatorView?.startAnimating()
    }
    
    func selectImage() -> UIImage? {
        return UIImage(named: "down_thin")
    }
}
