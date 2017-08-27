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
import ShoutitKit

class ConversationGroupWrapperViewController: UIViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var createPublicChatButton: UIButton!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRx()
    }
    
    // MARK: - Setup
    
    fileprivate func setupRx() {
        
        createPublicChatButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.flowDelegate?.showCreatePublicChat()
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupViews() {
        disclosureIndicatorImageView.image = UIImage.rightGreenArrowDisclosureIndicator()
        createPublicChatButton.contentHorizontalAlignment = Platform.isRTL ? .right : .left
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ConversationListTableViewController {
            controller.flowDelegate = self.flowDelegate
            controller.viewModel = PublicChatsListViewModel()
        }
    }
}
