//
//  ConversationGroupWrapperViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConversationGroupWrapperViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var createPublicChatButton: UIButton!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    // navigation
    weak var flowDelegate: ConversationListTableViewControllerFlowDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRx()
    }
    
    // MARK: - Setup
    
    private func setupRx() {
        
        createPublicChatButton
            .rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.flowDelegate?.showCreatePublicChat()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupViews() {
        disclosureIndicatorImageView.image = UIImage.rightGreenArrowDisclosureIndicator()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? ConversationListTableViewController {
            controller.flowDelegate = self.flowDelegate
            controller.viewModel = PublicChatsListViewModel()
        }
    }
}
