//
//  ChatsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ChatsFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    var deepLink : DPLDeepLink? {
        didSet {
            setupDeepLinkRoute()
        }
    }
    
    lazy var filterTransition: FilterTransition = {
        return FilterTransition()
    }()
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.chatsViewController()
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    func setupDeepLinkRoute() {
        guard let deepLink = deepLink else {
            return
        }
        
        if let parentController = self.navigationController.visibleViewController as? DeepLinkHandling {
            parentController.handleDeeplink(deepLink)
        }
    }
    
    func requiresLoggedInUser() -> Bool {
        return true
    }
}

extension ChatsFlowController: SearchShoutsResultsCollectionViewControllerFlowDelegate {}
extension ChatsFlowController: SearchViewControllerFlowDelegate {}
extension ChatsFlowController: ConversationListTableViewControllerFlowDelegate {}
extension ChatsFlowController: ConversationViewControllerFlowDelegate {}
extension ChatsFlowController: ShoutDetailTableViewControllerFlowDelegate {}
extension ChatsFlowController: ProfileCollectionViewControllerFlowDelegate {}
extension ChatsFlowController: NotificationsTableViewControllerFlowDelegate {}
extension ChatsFlowController: DiscoverShoutsParentViewControllerFlowDelegate {}
extension ChatsFlowController: DiscoverCollectionViewControllerFlowDelegate {}
extension ChatsFlowController: CallingOutViewControllerFlowDelegate {}
extension ChatsFlowController: ShoutsCollectionViewControllerFlowDelegate {}
extension ChatsFlowController: ConversationInfoViewControllerFlowDelegate {}