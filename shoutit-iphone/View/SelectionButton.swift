//
//  SelectionButton.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class SelectionButton: UIButton {
    
    // state
    private var disclosureType: DisclosureType {
        return DisclosureType(rawValue: ib_disclosureType) ?? .DownArrow
    }
    private var fieldTitleLabelMode: FieldTitleLabelMode = .None
    @IBInspectable private var isImageVisible: Bool = false
    private var isLoadingContent: Bool = false
    
    // state helpers
    @IBInspectable var ib_disclosureType: Int = 1
    
    // constraints
    private var _constraints: [NSLayoutConstraint] = []
    
    // views
    private var fieldTitleLabel: UILabel!
    private var disclosureIndicatorImageView : UIImageView!
    private var activityIndicatorView : UIActivityIndicatorView!
    private var iconImageView : UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addFieldTitleLabel()
        addIconImageView()
        addDisclosureImageView()
        addActivityIndicatorView()
    }
    
    // MARK: - Layout
    
    override func contentRectForBounds(bounds: CGRect) -> CGRect {
        
    }
    
    // layout
    
    private func setupConstraints() {
        NSLayoutConstraint.deactivateConstraints(_constraints)
        _constraints = []
        
        self.iconImageView.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0),
            NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0)])
        self.addConstraints([NSLayoutConstraint(item: iconImageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        self.selectImageView.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0),
            NSLayoutConstraint(item: selectImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)])
        self.addConstraints([NSLayoutConstraint(item: selectImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: selectImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        activityIndicator.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)])
        self.addConstraints([NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -9),
            NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)])
        
        self.activityIndicatorView = activityIndicator
    }
}

private extension SelectionButton {
    
    func generateConstraintsForIconImageView() -> [NSLayoutConstraint] {
        let views: [String : AnyObject] = ["icon" : iconImageView]
        switch (disclosureType, fieldTitleLabelMode, isImageVisible) {
        case (_, .None, true):
            return NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[icon(36)]", options: [], metrics: nil, views: views) +
            [NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
             NSLayoutConstraint(item: iconImageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 10.0)]
        case (_, .Small, true):
        default:
            
        }
    }
}

private extension SelectionButton {
    
    private func addFieldTitleLabel() {
        fieldTitleLabel = UILabel()
        fieldTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldTitleLabel.font = UIFont.sh_systemFontOfSize(12, weight: .Regular)
        fieldTitleLabel.textColor = UIColor(shoutitColor: .DiscoverBorder)
        addSubview(fieldTitleLabel)
    }
    
    private func addIconImageView() {
        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .ScaleAspectFit
        addSubview(iconImageView)
    }
    
    private func addDisclosureImageView() {
        disclosureIndicatorImageView = UIImageView()
        disclosureIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicatorImageView.contentMode = .ScaleAspectFit
        addSubview(disclosureIndicatorImageView)
    }
    
    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
    }
}

private extension SelectionButton {
    
    enum FieldTitleLabelMode {
        case None
        case Small
        case Big
        
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
}
