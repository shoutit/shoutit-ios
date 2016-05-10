//
//  ConversationSelectProfileAttachmentViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConversationSelectProfileAttachmentViewController: UIViewController, ContainerController {
    
    // RX
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var listChoiceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    // ContainerController
    weak var currentChildViewController: UIViewController?
    var currentControllerConstraints: [NSLayoutConstraint] = []
    
    var eventHandler: SelectProfileProfilesListEventHandler!
    
    lazy var listeningViewController: ProfilesListTableViewController = {[unowned self] in
        guard let username = Account.sharedInstance.user?.username else { fatalError() }
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        controller.eventHandler = self.eventHandler
        controller.viewModel = ListeningProfilesListViewModel(username: username)
        return controller
    }()
    
    lazy var listenersViewController: ProfilesListTableViewController = {[unowned self] in
        guard let username = Account.sharedInstance.user?.username else { fatalError() }
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        controller.eventHandler = self.eventHandler
        controller.viewModel = ListenersProfilesListViewModel(username: username)
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
    }
    
    private func setupRX() {
        
        listChoiceSegmentedControl
            .rx_value
            .asDriver()
            .driveNext {[unowned self] (value) in
                if value == 0 {
                    self.changeContentTo(self.listeningViewController)
                }
                else if value == 1 {
                    self.changeContentTo(self.listenersViewController)
                }
            }
            .addDisposableTo(disposeBag)
    }
}
