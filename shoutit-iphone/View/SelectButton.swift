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
    
    enum DisclosureType: Int {
        case None = 0
        case DownArrow = 1
        case RightArrow = 2
    }
    
    @IBInspectable var promptText : String?
    @IBInspectable var ib_disclosureType: Int = 1
    var disclosureType: DisclosureType {
        return DisclosureType(rawValue: ib_disclosureType) ?? .DownArrow
    }

    private var promptLabel : UILabel!
    private var selectImageView : UIImageView!
    
    var iconImageView : UIImageView!
    var hideIcon : Bool = false
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
        
        self.iconImageView = UIImageView()
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.iconImageView)
        
        self.iconImageView.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0),
            NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0)])
        self.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
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
        let xOffset : CGFloat = self.hideIcon == true ? 10.0 : 56.0
        if self.promptAvailable() {
            return CGRectMake(bounds.origin.x + xOffset, bounds.origin.y + 5, bounds.size.width - 40.0, bounds.size.height - 10)
        }

        return CGRectMake(bounds.origin.x + xOffset, bounds.origin.y + 0, bounds.size.width - 40.0, bounds.size.height)
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        return CGRectMake(10, CGRectGetMidY(contentRect) - 18.0, 36.0, 36.0)
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
    
    private func selectImage() -> UIImage? {
        switch disclosureType {
        case .None:
            return nil
        case .DownArrow:
            return UIImage.downArrowDisclosureIndicator()
        case .RightArrow:
            return UIImage.rightBlueArrowDisclosureIndicator()
        }
    }
}
