//
//  HomeFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class HomeFlowController: FlowController {
    
    let navigationController: UINavigationController
    lazy var filterTransition: FilterTransition = {
        return FilterTransition()
    }()
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.homeViewController()
        controller.flowDelegate = self

        navigationController.showViewController(controller, sender: nil)
    }
}

extension HomeFlowController: SearchShoutsResultsCollectionViewControllerFlowDelegate {}
extension HomeFlowController: SearchViewControllerFlowDelegate {}
extension HomeFlowController: HomeViewControllerFlowDelegate {}
extension HomeFlowController: ShoutDetailTableViewControllerFlowDelegate {}
extension HomeFlowController: ProfileCollectionViewControllerFlowDelegate {}
extension HomeFlowController: DiscoverShoutsParentViewControllerFlowDelegate {}
extension HomeFlowController: DiscoverCollectionViewControllerFlowDelegate {}
extension HomeFlowController: NotificationsTableViewControllerFlowDelegate {}
extension HomeFlowController: ConversationListTableViewControllerFlowDelegate {}
extension HomeFlowController: ConversationViewControllerFlowDelegate {}
extension HomeFlowController: CallingOutViewControllerFlowDelegate {}
extension HomeFlowController: ShoutsCollectionViewControllerFlowDelegate {}