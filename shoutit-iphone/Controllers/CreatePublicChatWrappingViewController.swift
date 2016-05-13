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

final class CreatePublicChatWrappingViewController: UIViewController {
    
    // RX
    private let disposeBag = DisposeBag()
    
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
    
    private func setupRX() {
        
        createButton
            .rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.notImplemented()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: nil)
        if let controller = segue.destinationViewController as? CreatePublicChatTableViewController {
            childViewController = controller
            controller.viewModel = viewModel
        }
    }
}
