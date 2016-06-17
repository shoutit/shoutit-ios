//
//  PromotedShoutViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class PromotedShoutViewController: UIViewController {
    
    var viewModel: PromotedShoutViewModel!
    weak var flowDelegate : FlowController?
    
    @IBOutlet weak var shoutTitleLabel: UILabel!
    @IBOutlet weak var promotionLabelViewContainer: UIView!
    @IBOutlet weak var availableShoutitCreditLabel: UILabel!
    var promotionLabelView: PromotionLabelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        configureViews()
    }
}

private extension PromotedShoutViewController {
    
    private func configureViews() {
        addPromotionLabelViewToContainer()
        hydrateViewsWithData()
    }
    
    private func addPromotionLabelViewToContainer() {
        promotionLabelView = PromotionLabelView.instanceFromNib()
        promotionLabelViewContainer.addSubview(promotionLabelView)
        let views: [String : AnyObject] = ["view" : promotionLabelView]
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(20)-[view]-(20)-|", options: [], metrics: nil, views: views))
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[view(90)]-|", options: [], metrics: nil, views: views))
    }
    
    private func hydrateViewsWithData() {
        shoutTitleLabel.text = viewModel.shout.title
        guard let promotionLabel = viewModel.shout.promotion?.label else { return }
        promotionLabelView.bindWithPromotionLabel(promotionLabel)
    }
}
