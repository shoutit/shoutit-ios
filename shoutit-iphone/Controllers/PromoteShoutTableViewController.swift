//
//  PromoteShoutTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class PromoteShoutTableViewController: UITableViewController {
    
    var viewModel: PromoteShoutViewModel!
    weak var flowDelegate : FlowController?
    private let disposeBag = DisposeBag()
    @IBOutlet weak var creditsBalanceLabel: UILabel!
    
    @IBOutlet weak var headerView : PromotionLabelsViews?
    
    private var options : [PromotionOption]? = []
    
    private var selectedOption : PromotionOption? {
        didSet {
            if let selectedOption = selectedOption {
                buyOption(selectedOption)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        setupRx()
        
        if let user = Account.sharedInstance.user as? DetailedProfile {
            setupRx()
            creditsBalanceLabel.text = "\(user.stats?.credit ?? 0)"
        }
        
        self.headerView?.fillWithShout(self.viewModel.shout)
    }
    
    func setupRx() {
        self.viewModel.getPromotionLabels().subscribeNext { [weak self] (labels) in
            self?.headerView?.presentPromotionLabels(labels)
        }.addDisposableTo(disposeBag)
        
        self.viewModel.getPromotionOptions().subscribeNext { [weak self] (labels) in
            self?.options = labels
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
        
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.creditsBalanceLabel.text = "\(stats?.credit ?? 0)"
        }.addDisposableTo(disposeBag)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = options else {
            return 1
        }
        return options.count > 0 ? options.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if options?.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("PromotionsLoadingPlaceholder", forIndexPath: indexPath)
        }
        
        // PromotionsOptionCell
        let cell = tableView.dequeueReusableCellWithIdentifier("PromotionsOptionCell", forIndexPath: indexPath) as! PromotionOptionTableViewCell
        
        guard let option = options?[indexPath.row] else {
            return cell
        }

        cell.bindWithOption(option)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let option = options?[indexPath.row] else {
            return
        }
        
        showPromoteAlert(option)
    }
    
    func showPromoteAlert(option: PromotionOption) {
        let alert = UIAlertController(title: NSLocalizedString("Promote Shout", comment: ""), message: NSLocalizedString("Confirm buying \(option.name) for \(option.credits) credits", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Buy", comment: ""), style: .Default, handler: { (action) in
            self.selectedOption = option
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func buyOption(option: PromotionOption) {
        self.viewModel.promoteShoutWithOption(option).subscribe { [weak self] (event) in
            switch event {
                case .Next(let promotion):
                    self?.navigationController?.showSuccessMessage(NSLocalizedString("Shout Promoted successfully", comment: ""))
                    self?.shoutPromoted(promotion)
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
            }
        }.addDisposableTo(disposeBag)
    }

    func shoutPromoted(promotion: Promotion) {

        let shout = viewModel.shout.copyShoutWithPromotion(promotion)

        self.dismissViewControllerAnimated(true) { [weak self] in
            self?.flowDelegate?.showPromotedViewWithShout(shout)
        }
    }
    
    
}
