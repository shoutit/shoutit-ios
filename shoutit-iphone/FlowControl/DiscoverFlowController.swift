//
//  DiscoverFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class DiscoverFlowController: FlowController {
    
    let navigationController: UINavigationController
    lazy var filterTransition: FilterTransition = {
        return FilterTransition()
    }()
    
    init(navigationController: UINavigationController, discoverItem: DiscoverItem? = nil) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.discoverViewController()
        controller.flowDelegate = self
        
        if let item = discoverItem {
            controller.viewModel = DiscoverGivenItemViewModel(discoverItem: item)
        } else {
            controller.viewModel = DiscoverGeneralViewModel()
        }

        navigationController.showViewController(controller, sender: nil)
    }
}

extension DiscoverFlowController: SearchShoutsResultsCollectionViewControllerFlowDelegate {}
extension DiscoverFlowController: SearchViewControllerFlowDelegate {}
extension DiscoverFlowController: DiscoverCollectionViewControllerFlowDelegate {}
extension DiscoverFlowController: ShoutDetailTableViewControllerFlowDelegate {}
extension DiscoverFlowController: ProfileCollectionViewControllerFlowDelegate {}
extension DiscoverFlowController: DiscoverShoutsParentViewControllerFlowDelegate {}
extension DiscoverFlowController: NotificationsTableViewControllerFlowDelegate {}
extension DiscoverFlowController: ConversationViewControllerFlowDelegate {}
extension DiscoverFlowController: ConversationListTableViewControllerFlowDelegate {}
extension DiscoverFlowController: CallingOutViewControllerFlowDelegate {}
extension DiscoverFlowController: ShoutsCollectionViewControllerFlowDelegate {}
extension DiscoverFlowController: ConversationInfoViewControllerFlowDelegate {}