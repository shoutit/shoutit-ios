//
//  BrowseFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BrowseFlowController: FlowController {
    
    let navigationController: UINavigationController
    lazy var filterTransition: FilterTransition = {
        return FilterTransition()
    }()
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        let controller = Wireframe.searchShoutsResultsCollectionViewController()
        controller.title = NSLocalizedString("Browse", comment: "")
        controller.viewModel = SearchShoutsResultsViewModel(searchPhrase: nil, inContext: .General)
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}

extension BrowseFlowController: SearchViewControllerFlowDelegate {}
extension BrowseFlowController: SearchShoutsResultsCollectionViewControllerFlowDelegate {}
extension BrowseFlowController: ShoutDetailTableViewControllerFlowDelegate {}
extension BrowseFlowController: DiscoverShoutsParentViewControllerFlowDelegate {}
extension BrowseFlowController: DiscoverCollectionViewControllerFlowDelegate {}
extension BrowseFlowController: ProfileCollectionViewControllerFlowDelegate {}
extension BrowseFlowController: TagsListTableViewControllerFlowDelegate {}
extension BrowseFlowController: NotificationsTableViewControllerFlowDelegate {}
extension BrowseFlowController: ConversationListTableViewControllerFlowDelegate {}
extension BrowseFlowController: ConversationViewControllerFlowDelegate {}
extension BrowseFlowController: CallingOutViewControllerFlowDelegate {}
extension BrowseFlowController: ShoutsCollectionViewControllerFlowDelegate {}
extension BrowseFlowController: ConversationInfoViewControllerFlowDelegate {}