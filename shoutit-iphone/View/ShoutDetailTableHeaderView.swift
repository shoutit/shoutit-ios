//
//  ShoutDetailTableHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum MarkButtonState {
    case MarkOfferSold
    case UnMarkOfferSold
    case MarkRequestFullfilled
    case UnMarkRequestFullfilled
    case None
}

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
    @IBOutlet weak var markButton: CustomUIButton!
    
    
    // constraints
    @IBOutlet weak var titleLabelToBottomConstraints: NSLayoutConstraint!
    
    var markButtonVisible = false {
        didSet {
            self.adjustBottomHeight()
            self.markButton.hidden = !markButtonVisible
        }
    }
    var priceLabelVisible = false
    
    var markButtonHeight : CGFloat {
        return self.markButtonVisible ? 64.0 : 0.0
    }
    
    var markButtonState : MarkButtonState = .None {
        didSet {
            self.adjustMarkButton(markButtonState)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        internalContainerView.layer.masksToBounds = true
        internalContainerView.layer.cornerRadius = 4
        internalContainerView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        internalContainerView.layer.borderColor = UIColor(shoutitColor: .CellBackgroundGrayColor).CGColor
    }
    
    func setConstraintForPriceLabelVisible(visible: Bool) {
        priceLabelVisible = visible
        adjustBottomHeight()
    }
    
    func adjustBottomHeight() {
        titleLabelToBottomConstraints.constant = priceLabelVisible ? 30 + self.markButtonHeight : 8 + self.markButtonHeight
    }
    
    private func adjustMarkButton(state: MarkButtonState) {
        
        self.markButton.borderColor = UIColor(shoutitColor: .PrimaryGreen)
        self.markButton.setTitleColor(UIColor(shoutitColor: .PrimaryGreen), forState: .Normal)
        self.markButton.borderWidth = 1.5
        
        switch state {
        case .MarkOfferSold:
            self.markButton.setTitle(NSLocalizedString("Mark as Sold", comment: ""), forState: .Normal)
        case .UnMarkOfferSold:
            self.markButton.setTitle(NSLocalizedString("Unmark as Sold", comment: ""), forState: .Normal)
            self.markButton.borderColor = UIColor(shoutitColor: .PrimaryGreen).colorWithAlphaComponent(0.5)
            self.markButton.setTitleColor(UIColor(shoutitColor: .PrimaryGreen).colorWithAlphaComponent(0.5), forState: .Normal)
        case .MarkRequestFullfilled:
            self.markButton.setTitle(NSLocalizedString("Mark as Fulfilled", comment: ""), forState: .Normal)
        case .UnMarkRequestFullfilled:
            self.markButton.setTitle(NSLocalizedString("Unmark as Fulfilled", comment: ""), forState: .Normal)
            self.markButton.borderColor = UIColor(shoutitColor: .PrimaryGreen).colorWithAlphaComponent(0.5)
            self.markButton.setTitleColor(UIColor(shoutitColor: .PrimaryGreen).colorWithAlphaComponent(0.5), forState: .Normal)
        default: self.markButton.setTitle("", forState: .Normal)
        }
    }
}
