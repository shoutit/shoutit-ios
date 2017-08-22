//
//  ConversationListsParentViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ConversationListsParentViewController: UIViewController, ContainerController {
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var listChoiceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var loadWithNavigationItem : NavigationItem?
    
    // ContainerController
    weak var currentChildViewController: UIViewController?
    var currentControllerConstraints: [NSLayoutConstraint] = []
    
    // navigation
    weak var flowDelegate: FlowController?
    
    lazy var myChatsViewController: ConversationListTableViewController = {[unowned self] in
        let controller = Wireframe.chatsListTableViewController()
        controller.viewModel = ConversationListViewModel()
        controller.flowDelegate = self.flowDelegate
        return controller
        }()
    
    lazy var publicChatsViewController: ConversationGroupWrapperViewController = {[unowned self] in
        let controller = Wireframe.groupChatsViewController()
        controller.flowDelegate = self.flowDelegate
        return controller
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        setupNavigationBar()
    
    }
    
    func openCorrectPage() {
        if loadWithNavigationItem == .PublicChats {
            self.switchToPublicChats()
        } else if loadWithNavigationItem == .Chats {
            self.switchToMyChats()
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    func switchToPublicChats() {
        listChoiceSegmentedControl.selectedSegmentIndex = 1
        self.changeContentTo(self.publicChatsViewController)
    }
    
    func switchToMyChats() {
        listChoiceSegmentedControl.selectedSegmentIndex = 0
        self.changeContentTo(self.myChatsViewController)
    }
    
    fileprivate func setupRX() {
        
        listChoiceSegmentedControl
            .rx_value
            .asDriver()
            .driveNext {[unowned self] (value) in
                if value == 0 {
                    self.changeContentTo(self.myChatsViewController)
                }
                else if value == 1 {
                    self.changeContentTo(self.publicChatsViewController)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func searchAction(_ sender: AnyObject) {
        flowDelegate?.showSearchInContext(.general)
    }
}

extension ConversationListsParentViewController : DeepLinkHandling {
    func handleDeeplink(_ deepLink: DPLDeepLink) {
        self.loadWithNavigationItem = deepLink.navigationItem
        
        if let _ = self.view {
            openCorrectPage()
        }
    }
}
