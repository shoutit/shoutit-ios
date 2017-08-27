//
//  SelectionButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

final class SelectionButton: UIButton, UIGestureRecognizerDelegate {
    
    // state
    fileprivate var disclosureType: DisclosureType {
        return DisclosureType(rawValue: ib_disclosureType) ?? .downArrow
    }
    fileprivate var fieldTitleLabelMode: FieldTitleLabelMode {
        return FieldTitleLabelMode(rawValue: ib_fieldTitleLabelType) ?? .none
    }
    fileprivate var iconImageType: IconImageType {
        return IconImageType(rawValue: ib_iconImageType) ?? .small
    }
    @IBInspectable var isImageVisible: Bool = false
    
    // state helpers
    @IBInspectable var ib_disclosureType: Int = 1
    @IBInspectable var ib_fieldTitleLabelType: Int = 0
    @IBInspectable var ib_iconImageType: Int = 0
    @IBInspectable var fieldTitleLabelFontColor: UIColor = UIColor(shoutitColor: .discoverBorder)
    @IBInspectable var sh_borderWidth: CGFloat = 1
    
    // constraints
    fileprivate var _constraints: [NSLayoutConstraint] = []
    
    // views
    fileprivate(set) var fieldTitleLabel: UILabel!
    fileprivate(set) var iconImageView : UIImageView!
    fileprivate var disclosureIndicatorImageView : UIImageView!
    fileprivate var activityIndicatorView : UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
        addFieldTitleLabel()
        addIconImageView()
        addDisclosureImageView()
        addActivityIndicatorView()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    func showActivity(_ show: Bool) {
        isUserInteractionEnabled = !show
        titleLabel?.alpha = show ? 0.0 : 1.0
        fieldTitleLabel.isHidden = show
        disclosureIndicatorImageView.isHidden = show
        iconImageView.isHidden = show
        activityIndicatorView.isHidden = !show
        if show {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    func showIcon(_ show: Bool) {
        isImageVisible = show
        setupConstraints()
    }
    
    // MARK: - Layout
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        var leadingInset: CGFloat = 0
        var trailingInset: CGFloat = 0
        var topInset: CGFloat = 0
        
        switch disclosureType {
        case .none: break
        default: trailingInset = 30
        }
        
        switch fieldTitleLabelMode {
        case .none: topInset = 19
        case .big: topInset = 31
        case .small: topInset = 23
        case .verySmall: topInset = 10
        }
        
        switch (isImageVisible, iconImageType) {
        case (true, .small): leadingInset = 42
        case (true, .big): leadingInset = 56
        default: leadingInset = 10
        }
        
        let x: CGFloat
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            x = trailingInset
        } else {
            x = leadingInset
        }
        return CGRect(x: x,
                      y: topInset,
                      width: bounds.width - leadingInset - trailingInset,
                      height: titleFontSize())
    }
    
    // MARK: - Layout
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.deactivate(_constraints)
        _constraints = []
        _constraints += generateConstraintsForIconImageView()
        _constraints += generateConstraintsForFieldTitleLabel()
        _constraints += generateConstraintsForDisclosureIndicatorImageView()
        _constraints += generateConstraintsForActivityIndicatorView()
        NSLayoutConstraint.activate(_constraints)
    }
}

private extension SelectionButton {
    
    func generateConstraintsForIconImageView() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["icon" : iconImageView]
        switch (disclosureType, fieldTitleLabelMode, isImageVisible, iconImageType) {
        case (_, .none, true, .small):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[icon(18)]", options: [], metrics: nil, views: views) +
            [NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
             NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18.0)]
        case (_, .small, true, .small):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[icon(18)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-23-[icon(18)]", options: [], metrics: nil, views: views)
        case (_, .none, true, .big):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[icon(36)]", options: [], metrics: nil, views: views) +
                [NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36.0)]
        case (_, .small, true, .big):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[icon(36)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-23-[icon(36)]", options: [], metrics: nil, views: views)
        default:
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|[icon(0)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[icon(0)]", options: [], metrics: nil, views: views)
        }
    }
    
    func generateConstraintsForFieldTitleLabel() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["text" : fieldTitleLabel,
                                           "disclosure" : disclosureIndicatorImageView]
        switch (disclosureType, fieldTitleLabelMode, isImageVisible) {
        case (_, .small, _):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[text]-(>=8)-[disclosure]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[text]", options: [], metrics: nil, views: views)
        case (_, .big, _):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[text]-(>=8)-[disclosure]", options: [], metrics: nil, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[text]", options: [], metrics: nil, views: views)
        default:
            return NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[text(0)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[text(0)]", options: [], metrics: nil, views: views)
        }
    }
    
    func generateConstraintsForDisclosureIndicatorImageView() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["disclosure" : disclosureIndicatorImageView]
        let centerConstraint = NSLayoutConstraint(item: disclosureIndicatorImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: disclosureIndicatorImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18.0)
        switch (disclosureType, fieldTitleLabelMode, isImageVisible) {
        case (.none, _, _):
            return NSLayoutConstraint.constraints(withVisualFormat: "H:[disclosure(0)]-0-|", options: [], metrics: nil, views: views) + [centerConstraint, heightConstraint]
        default:
            return NSLayoutConstraint.constraints(withVisualFormat: "H:[disclosure(18)]-10-|", options: [], metrics: nil, views: views) + [centerConstraint, heightConstraint]
        }
    }
    
    func generateConstraintsForActivityIndicatorView() -> [NSLayoutConstraint] {
        return [NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)]
    }
}

private extension SelectionButton {
    
    func setupAppearance() {
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize())
        titleLabel?.setContentCompressionResistancePriority(1000, for: .horizontal)
        
        layer.cornerRadius = 4.0
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor(shoutitColor: .textFieldBorderGrayColor).cgColor
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            contentHorizontalAlignment = .right
        } else {
            contentHorizontalAlignment = .left
        }
        contentVerticalAlignment = .center
    }
    
    func addFieldTitleLabel() {
        fieldTitleLabel = UILabel()
        fieldTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldTitleLabel.font = UIFont.sh_systemFontOfSize(fieldTitleLabelMode.fontSize, weight: .regular)
        fieldTitleLabel.textColor = fieldTitleLabelFontColor
        fieldTitleLabel.clipsToBounds = true
        addSubview(fieldTitleLabel)
    }
    
    func addIconImageView() {
        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        addSubview(iconImageView)
    }
    
    func addDisclosureImageView() {
        disclosureIndicatorImageView = UIImageView()
        disclosureIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicatorImageView.contentMode = .scaleAspectFit
        disclosureIndicatorImageView.clipsToBounds = true
        disclosureIndicatorImageView.image = disclosureType.image
        addSubview(disclosureIndicatorImageView)
    }
    
    func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
    }
}

private extension SelectionButton {
    
    enum IconImageType: Int {
        case small = 0
        case big = 1
    }
    
    enum FieldTitleLabelMode: Int {
        case none = 0
        case small = 1
        case big = 2
        case verySmall = 3
        
        var fontSize: CGFloat {
            switch self {
            case .none: return 0
            case .small: return 12
            case .big: return 18
            case .verySmall: return 12
            }
        }
    }
    
    enum DisclosureType: Int {
        case none = 0
        case downArrow = 1
        case rightArrow = 2
        
        var image: UIImage? {
            switch self {
            case .none: return nil
            case .downArrow: return UIImage.downArrowDisclosureIndicator()
            case .rightArrow: return UIImage.rightBlueArrowDisclosureIndicator()
            }
        }
    }
    
    func titleFontSize() -> CGFloat {
        switch fieldTitleLabelMode {
        case .big: return 12
        case .small: return 18
        case .none: return 18
        case .verySmall: return 15
        }
    }
}
