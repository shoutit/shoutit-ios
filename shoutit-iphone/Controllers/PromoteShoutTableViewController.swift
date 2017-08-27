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
    fileprivate let disposeBag = DisposeBag()
    @IBOutlet weak var creditsBalanceLabel: UILabel!
    
    @IBOutlet weak var headerView : PromotionLabelsViews?
    
    fileprivate var options : [PromotionOption]? = []
    
    fileprivate var selectedOption : PromotionOption? {
        didSet {
            if let selectedOption = selectedOption {
                buyOption(selectedOption)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
       
        if let user = Account.sharedInstance.user as? DetailedUserProfile {
            setupRx()
            creditsBalanceLabel.text = "\(user.stats?.credit ?? 0)"
        }
        
        self.headerView?.fillWithShout(self.viewModel.shout)
    }
    
    func setupRx() {
        self.viewModel.getPromotionLabels().subscribe(onNext: { [weak self] (labels) in
            self?.headerView?.presentPromotionLabels(labels)
        }).addDisposableTo(disposeBag)
        
        self.viewModel.getPromotionOptions().subscribe(onNext: { [weak self] (labels) in
            self?.options = labels
            self?.tableView.reloadData()
        }).addDisposableTo(disposeBag)
        
        Account.sharedInstance.statsSubject.subscribe(onNext: { [weak self] (stats) in
            self?.creditsBalanceLabel.text = "\(stats?.credit ?? 0)"
        }).addDisposableTo(disposeBag)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = options else {
            return 1
        }
        return options.count > 0 ? options.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if options?.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "PromotionsLoadingPlaceholder", for: indexPath)
        }
        
        // PromotionsOptionCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionsOptionCell", for: indexPath) as! PromotionOptionTableViewCell
        
        guard let option = options?[indexPath.row] else {
            return cell
        }

        cell.bindWithOption(option)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = options?[indexPath.row] else {
            return
        }
        
        showPromoteAlert(option)
    }
    
    func showPromoteAlert(_ option: PromotionOption) {
        let alert = UIAlertController(title: NSLocalizedString("Promote Shout", comment: "Promote Shout"), message: NSLocalizedString("Confirm buying \(option.name) for \(option.credits) credits", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Buy", comment: "Promote Shout"), style: .default, handler: { (action) in
            self.selectedOption = option
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: { (action) in
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func buyOption(_ option: PromotionOption) {
        self.viewModel.promoteShoutWithOption(option).subscribe { [weak self] (event) in
            switch event {
                case .next(let promotion):
                    self?.navigationController?.showSuccessMessage(NSLocalizedString("Shout Promoted successfully", comment: "Promoted Shout Success Message"))
                    self?.shoutPromoted(promotion)
                case .error(let error):
                    self?.showError(error)
                default:
                    break
            }
        }.addDisposableTo(disposeBag)
    }

    func shoutPromoted(_ promotion: Promotion) {

        let shout = viewModel.shout.copyShoutWithPromotion(promotion)

        self.dismiss(animated: true) { [weak self] in
            self?.flowDelegate?.showPromotedViewWithShout(shout)
        }
    }
    
    
}
