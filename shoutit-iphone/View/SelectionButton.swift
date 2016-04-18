//
//  SelectionButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

final class SelectionButton: UIButton {
    
    // state
    private var disclosureType: DisclosureType {
        return DisclosureType(rawValue: ib_disclosureType) ?? .DownArrow
    }
    private var fieldTitleLabelMode: FieldTitleLabelMode {
        return FieldTitleLabelMode(rawValue: ib_fieldTitleLabelType) ?? .None
    }
    private var iconImageType: IconImageType {
        return IconImageType(rawValue: ib_iconImageType) ?? .Small
    }
    @IBInspectable var isImageVisible: Bool = false
    
    // state helpers
    @IBInspectable var ib_disclosureType: Int = 1
    @IBInspectable var ib_fieldTitleLabelType: Int = 0
    @IBInspectable var ib_iconImageType: Int = 0
    @IBInspectable var fieldTitleLabelFontColor: UIColor = UIColor(shoutitColor: .DiscoverBorder)
    
    // constraints
    private var _constraints: [NSLayoutConstraint] = []
    
    // views
    private(set) var fieldTitleLabel: UILabel!
    private(set) var iconImageView : UIImageView!
    private var disclosureIndicatorImageView : UIImageView!
    private var activityIndicatorView : UIActivityIndicatorView!
    
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
    
    func showActivity(show: Bool) {
        userInteractionEnabled = !show
        titleLabel?.alpha = show ? 0.0 : 1.0
        fieldTitleLabel.hidden = show
        disclosureIndicatorImageView.hidden = show
        iconImageView.hidden = show
        activityIndicatorView.hidden = !show
        if show {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    func showIcon(show: Bool) {
        isImageVisible = show
        setupConstraints()
    }
    
    // MARK: - Layout
    
    override func contentRectForBounds(bounds: CGRect) -> CGRect {
        var leadingInset: CGFloat = 0
        var trailingInset: CGFloat = 0
        var topInset: CGFloat = 0
        
        switch disclosureType {
        case .None: break
        default: trailingInset = 30
        }
        
        switch fieldTitleLabelMode {
        case .None: topInset = 19
        case .Big: topInset = 31
        case .Small: topInset = 23
        }
        
        switch (isImageVisible, iconImageType) {
        case (true, .Small): leadingInset = 42
        case (true, .Big): leadingInset = 56
        default: leadingInset = 10
        }
        
        let x: CGFloat
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
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
    
    private func setupConstraints() {
        NSLayoutConstraint.deactivateConstraints(_constraints)
        _constraints = []
        _constraints += generateConstraintsForIconImageView()
        _constraints += generateConstraintsForFieldTitleLabel()
        _constraints += generateConstraintsForDisclosureIndicatorImageView()
        _constraints += generateConstraintsForActivityIndicatorView()
        NSLayoutConstraint.activateConstraints(_constraints)
    }
}

private extension SelectionButton {
    
    func generateConstraintsForIconImageView() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["icon" : iconImageView]
        switch (disclosureType, fieldTitleLabelMode, isImageVisible, iconImageType) {
        case (_, .None, true, .Small):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[icon(18)]", options: [], metrics: nil, views: views) +
            [NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
             NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)]
        case (_, .Small, true, .Small):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[icon(18)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-23-[icon(18)]", options: [], metrics: nil, views: views)
        case (_, .None, true, .Big):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[icon(36)]", options: [], metrics: nil, views: views) +
                [NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0)]
        case (_, .Small, true, .Big):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[icon(36)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-23-[icon(36)]", options: [], metrics: nil, views: views)
        default:
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|[icon(0)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraintsWithVisualFormat("V:|[icon(0)]", options: [], metrics: nil, views: views)
        }
    }
    
    func generateConstraintsForFieldTitleLabel() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["text" : fieldTitleLabel,
                                           "disclosure" : disclosureIndicatorImageView]
        switch (disclosureType, fieldTitleLabelMode, isImageVisible) {
        case (_, .Small, _):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[text]-(>=8)-[disclosure]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[text]", options: [], metrics: nil, views: views)
        case (_, .Big, _):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[text]-(>=8)-[disclosure]", options: [], metrics: nil, views: views) +
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-7-[text]", options: [], metrics: nil, views: views)
        default:
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[text(0)]", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[text(0)]", options: [], metrics: nil, views: views)
        }
    }
    
    func generateConstraintsForDisclosureIndicatorImageView() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["disclosure" : disclosureIndicatorImageView]
        let centerConstraint = NSLayoutConstraint(item: disclosureIndicatorImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: disclosureIndicatorImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)
        switch (disclosureType, fieldTitleLabelMode, isImageVisible) {
        case (.None, _, _):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:[disclosure(0)]-0-|", options: [], metrics: nil, views: views) + [centerConstraint, heightConstraint]
        default:
            return NSLayoutConstraint.constraintsWithVisualFormat("H:[disclosure(18)]-10-|", options: [], metrics: nil, views: views) + [centerConstraint, heightConstraint]
        }
    }
    
    func generateConstraintsForActivityIndicatorView() -> [NSLayoutConstraint] {
        return [NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)]
    }
}

private extension SelectionButton {
    
    private func setupAppearance() {
        titleLabel?.font = UIFont.systemFontOfSize(titleFontSize())
        titleLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0
        layer.borderColor = MaterialColor.grey.lighten1.CGColor
        
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            contentHorizontalAlignment = .Right
        } else {
            contentHorizontalAlignment = .Left
        }
        contentVerticalAlignment = .Center
    }
    
    private func addFieldTitleLabel() {
        fieldTitleLabel = UILabel()
        fieldTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldTitleLabel.font = UIFont.sh_systemFontOfSize(fieldTitleLabelMode.fontSize, weight: .Regular)
        fieldTitleLabel.textColor = fieldTitleLabelFontColor
        fieldTitleLabel.clipsToBounds = true
        addSubview(fieldTitleLabel)
    }
    
    private func addIconImageView() {
        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .ScaleAspectFit
        iconImageView.clipsToBounds = true
        addSubview(iconImageView)
    }
    
    private func addDisclosureImageView() {
        disclosureIndicatorImageView = UIImageView()
        disclosureIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicatorImageView.contentMode = .ScaleAspectFit
        disclosureIndicatorImageView.clipsToBounds = true
        disclosureIndicatorImageView.image = disclosureType.image
        addSubview(disclosureIndicatorImageView)
    }
    
    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
    }
}

private extension SelectionButton {
    
    enum IconImageType: Int {
        case Small = 0
        case Big = 1
    }
    
    enum FieldTitleLabelMode: Int {
        case None = 0
        case Small = 1
        case Big = 2
        
        var fontSize: CGFloat {
            switch self {
            case .None: return 0
            case .Small: return 12
            case .Big: return 18
            }
        }
    }
    
    enum DisclosureType: Int {
        case None = 0
        case DownArrow = 1
        case RightArrow = 2
        
        var image: UIImage? {
            switch self {
            case .None: return nil
            case .DownArrow: return UIImage.downArrowDisclosureIndicator()
            case .RightArrow: return UIImage.rightBlueArrowDisclosureIndicator()
            }
        }
    }
    
    func titleFontSize() -> CGFloat {
        switch fieldTitleLabelMode {
        case .Big: return 12
        case .Small: return 18
        case .None: return 18
        }
    }
}
