//
//  DiscoverShoutsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class DiscoverShoutsFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, discoverItem: DiscoverItem? = nil) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.discoverShoutsViewController()
        controller.flowDelegate = self
        
        if let item = discoverItem {
            controller.viewModel = DiscoverShoutsViewModel(discoverItem: item)
        }
        
        navigationController.showViewController(controller, sender: nil)
    }
}

extension DiscoverShoutsFlowController: SearchUserResultsTableViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: SearchShoutsResultsCollectionViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: SearchViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: DiscoverShoutsParentViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: ShoutDetailTableViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: ProfileCollectionViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: DiscoverCollectionViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: NotificationsTableViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: ConversationViewControllerFlowDelegate {}
extension DiscoverShoutsFlowController: ConversationListTableViewControllerFlowDelegate {}