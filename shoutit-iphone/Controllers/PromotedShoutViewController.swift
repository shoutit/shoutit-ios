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
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        configureViews()
        
        if let user = Account.sharedInstance.user as? DetailedUserProfile {
            availableShoutitCreditLabel.text = "\(user.stats?.credit ?? 0)"
        }
        
        Account.sharedInstance.statsSubject.subscribe(onNext: { [weak self] (stats) in
            self?.availableShoutitCreditLabel.text = "\(stats?.credit ?? 0)"
            }).addDisposableTo(disposeBag)
    }
    
}



private extension PromotedShoutViewController {
    
    func configureViews() {
        addPromotionLabelViewToContainer()
        hydrateViewsWithData()
    }
    
    func addPromotionLabelViewToContainer() {
        promotionLabelView = PromotionLabelView.instanceFromNib()
        promotionLabelView.translatesAutoresizingMaskIntoConstraints = false
        promotionLabelViewContainer.addSubview(promotionLabelView)
        let views: [String : AnyObject] = ["view" : promotionLabelView]
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", options: [], metrics: nil, views: views))
        promotionLabelViewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-|", options: [], metrics: nil, views: views))
        promotionLabelViewContainer.layoutIfNeeded()
        promotionLabelView.setNeedsLayout()
    }
    
    func hydrateViewsWithData() {
        shoutTitleLabel.text = viewModel.shout.title
        guard let promotionLabel = viewModel.shout.promotion else { return }
        bindWithPromotionLabel(promotionLabel)
    }
    
    func bindWithPromotionLabel(_ promo: Promotion) {
        promotionLabelView.sentenceLabel?.text = promo.label?.description
        promotionLabelView.topLabel?.text = promo.label?.name
        
        if let days = promo.days, let expiresAt = promo.expiresAt {
            promotionLabelView.daysLeftLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%@ days", comment: "Your shout is promoted until \(DateFormatters.sharedInstance.stringFromDateEpoch(expiresAt))"), NSNumber(value: days as Int))
            promotionLabelView.daysLeftLabel?.isHidden = false
            promotionLabelView.sentenceLabel?.text = NSLocalizedString("Your shout is promoted until \(DateFormatters.sharedInstance.stringFromDateEpoch(expiresAt))", comment: "Expiry date")
        } else {
            promotionLabelView.daysLeftLabel?.text = NSLocalizedString("", comment: "Your shout is promoted")
            promotionLabelView.daysLeftLabel?.isHidden = false
            promotionLabelView.sentenceLabel?.text = NSLocalizedString("Your shout is promoted", comment: "Days null")
        }
        
        promotionLabelView.topLabelBackground?.backgroundColor = promo.label?.color()
        promotionLabelView.backgroundView?.backgroundColor = promo.label?.backgroundUIColor()
    }
    
    
}
