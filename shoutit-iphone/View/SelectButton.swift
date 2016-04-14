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
    
    @IBInspectable var ib_disclosureType: Int = 1
    var disclosureType: DisclosureType {
        return DisclosureType(rawValue: ib_disclosureType) ?? .DownArrow
    }
    var optionsLoaded = true {
        didSet {
            self.titleLabel?.alpha = optionsLoaded ? 1.0 : 0.0
            setActivityIndicatorVisible(!optionsLoaded)
            self.userInteractionEnabled = optionsLoaded
        }
    }
    var hideIcon : Bool = false
    
    // views
    private var selectImageView : UIImageView!
    private var activityIndicatorView : UIActivityIndicatorView?
    var iconImageView : UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
        addIconImageView()
        addDisclosureImageView()
        addActivityIndicatorView()
    }
    
    // MARK: - Overrides
    
    override func contentRectForBounds(bounds: CGRect) -> CGRect {
        let xOffset : CGFloat = self.hideIcon == true ? 10.0 : 56.0

        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return CGRect(x: bounds.origin.x + 40.0,
                          y: bounds.origin.y + 0,
                          width: bounds.size.width - xOffset - 40.0,
                          height: bounds.size.height)
        } else {
            return CGRect(x: bounds.origin.x + xOffset,
                          y: bounds.origin.y + 0,
                          width: bounds.size.width - 40.0,
                          height: bounds.size.height)
        }
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return CGRectMake(CGRectGetMaxX(contentRect) - 10 - 36.0, CGRectGetMidY(contentRect) - 18.0, 36.0, 36.0)
        } else {
            return CGRectMake(10, CGRectGetMidY(contentRect) - 18.0, 36.0, 36.0)
        }
    }
    
    // MARK: - Actions
    
    func setActivityIndicatorVisible(value: Bool) {
        if value {
            showActivityIndicator()
        } else {
            hideActivityIndicator()
        }
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        self.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        self.titleLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = MaterialColor.grey.lighten1.CGColor
        
        self.contentHorizontalAlignment = .Left
        self.contentVerticalAlignment = .Center
    }
    
    private func addIconImageView() {
        self.iconImageView = UIImageView()
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.iconImageView)
        
        self.iconImageView.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0),
            NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0)])
        self.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
    }
    
    private func addDisclosureImageView() {
        self.selectImageView = UIImageView(image: selectImage())
        self.selectImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.selectImageView)
        
        self.selectImageView.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0),
            NSLayoutConstraint(item: selectImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)])
        self.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: selectImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
    }
    
    private func addActivityIndicatorView() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        activityIndicator.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)])
        self.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -9),
            NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        self.activityIndicatorView = activityIndicator
    }
    
    // MARK: - Helpers
    
    private func showActivityIndicator() {
        self.activityIndicatorView?.hidden = false
        self.activityIndicatorView?.startAnimating()
    }
    
    private func hideActivityIndicator() {
        self.activityIndicatorView?.hidden = true
        self.activityIndicatorView?.stopAnimating()
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
