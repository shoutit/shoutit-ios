//
//  CreatePublicChatWrappingViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MBProgressHUD

final class CreatePublicChatWrappingViewController: UIViewController {
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // outlets
    @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var createButton: CustomUIButton!
    
    // child
    weak var childViewController: CreatePublicChatTableViewController?
    
    // view model
    var viewModel: CreatePublicChatViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(bottomLayoutGuideConstraint)
        setupRX()
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        createButton
            .rx_tap
            .flatMapFirst {[unowned self] () -> Observable<CreatePublicChatViewModel.OperationStatus> in
                return self.viewModel.createChat()
            }
            .observeOn(MainScheduler.instance).subscribeNext {[weak self] (status) in
                switch status {
                case .error(let error):
                    self?.showError(error)
                case .progress(let show):
                    if show {
                        MBProgressHUD.showAdded(to: self?.view, animated: true)
                    } else {
                        MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                    }
                case .ready:
                    self?.dismiss()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        if let controller = segue.destination as? CreatePublicChatTableViewController {
            childViewController = controller
            controller.viewModel = viewModel
        }
    }
}
