//
//  AdminsListParentViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShoutitKit

final class AdminsListParentViewController: UIViewController {
    
    @IBOutlet weak var addAdminsButton: UIButton!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    var viewModel: AdminsListViewModel!
    weak var flowDelegate: FlowController?
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        setupViews()
        setupRX()
    }
    
    // MARK: - Setup
    
    fileprivate func setupViews() {
        disclosureIndicatorImageView.image = UIImage.rightGreenArrowDisclosureIndicator()
        addAdminsButton.contentHorizontalAlignment = Platform.isRTL ? .right : .left
    }
    
    fileprivate func setupRX() {
        
        addAdminsButton
            .rx_tap
            .asDriver().driveNext{ [weak self] in
                self?.addAdmin()
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .errorSubject
            .observeOn(MainScheduler.instance).subscribeNext { [weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .successSubject
            .observeOn(MainScheduler.instance).subscribeNext { [weak self] (success) in
                self?.showSuccessMessage(success.message)
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? AdminsListTableViewController {
            controller.viewModel = viewModel
            controller.flowDelegate = flowDelegate
        }
    }
    
    // MARL: - Actions
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.general)
    }
}

private extension AdminsListParentViewController {
    
    func addAdmin() {
        guard case .some(.page(let user, _)) = Account.sharedInstance.loginState else {
            assertionFailure()
            return
        }
        let eventHandler = SelectProfileProfilesListEventHandler { [weak self] (profile) in
            self?.viewModel.addAdmin(profile)
        }
        flowDelegate?.showAddAdminChoiceViewControllerWithProfile(Profile.profileWithUser(user), withEventHandler: eventHandler)
    }
}
