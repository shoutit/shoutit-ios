//
//  ShoutDetailTableHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutDetailTableHeaderView: UIView {
    
    @IBOutlet weak var internalContainerView: UIView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorProfileImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var shoutTypeLabel: UILabel!
    @IBOutlet weak var pageViewControllerContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var addToCartButton: CustomUIButton!
    @IBOutlet weak var showProfileButton: UIButton!
    
    // constraints
    @IBOutlet weak var titleLabelToBottomConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        internalContainerView.layer.masksToBounds = true
        internalContainerView.layer.cornerRadius = 4
        internalContainerView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        internalContainerView.layer.borderColor = UIColor(shoutitColor: .CellBackgroundGrayColor).CGColor
    }
    
    func setConstraintForPriceLabelVisible(visible: Bool) {
        titleLabelToBottomConstraints.constant = visible ? 30 : 8
    }
}
