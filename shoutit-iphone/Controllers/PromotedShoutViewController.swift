//
//  PromotedShoutViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import RxSwift

final class PromotedShoutViewController: UIViewController {
    
    var viewModel: PromotedShoutViewModel!
    weak var flowDelegate : FlowController?
    
    @IBOutlet weak var shoutTitleLabel: UILabel!
    @IBOutlet weak var promotionLabelViewContainer: UIView!
    @IBOutlet weak var availableShoutitCreditLabel: UILabel!
    var promotionLabelView: PromotionLabelView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        configureViews()
        
        if let user = Account.sharedInstance.user as? DetailedProfile {
            availableShoutitCreditLabel.text = "\(user.stats?.credit ?? 0)"
        }
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.availableShoutitCreditLabel.text = "\(stats?.credit ?? 0)"
            }.addDisposableTo(disposeBag)
    }
    
}



private extension PromotedShoutViewController {
    
    private func configureViews() {
        addPromotionLabelViewToContainer()
        hydrateViewsWithData()
    }
    
    private func addPromotionLabelViewToContainer() {
        promotionLabelView = PromotionLabelView.instanceFromNib()
        promotionLabelView.translatesAutoresizingMaskIntoConstraints = false
        promotionLabelViewContainer.addSubview(promotionLabelView)
        let views: [String : AnyObject] = ["view" : promotionLabelView]
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[view]-|", options: [], metrics: nil, views: views))
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[view]-|", options: [], metrics: nil, views: views))
        promotionLabelViewContainer.layoutIfNeeded()
        promotionLabelView.setNeedsLayout()
    }
    
    private func hydrateViewsWithData() {
        shoutTitleLabel.text = viewModel.shout.title
        guard let promotionLabel = viewModel.shout.promotion else { return }
        bindWithPromotionLabel(promotionLabel)
    }
    
    func bindWithPromotionLabel(promo: Promotion) {
        promotionLabelView.sentenceLabel?.text = promo.label?.description
        promotionLabelView.topLabel?.text = promo.label?.name
        
        if let days = promo.days {
            promotionLabelView.daysLeftLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%@ days", comment: "days count label on promotion shout"), NSNumber(integer: days))
            promotionLabelView.daysLeftLabel?.hidden = false
        }
        
        promotionLabelView.topLabelBackground?.backgroundColor = promo.label?.color()
        promotionLabelView.backgroundView?.backgroundColor = promo.label?.backgroundUIColor()
    }
    
    
}