//
//  ListenersDisplaybale.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ListenersDisplaybale {
    func showListenersForUsername(username: String) -> Void
    func showListeningForUsername(username: String) -> Void
    func showInterestsForUsername(username: String) -> Void
}

extension ListenersDisplaybale where Self: FlowController, Self: ProfileDisplayable, Self: PageDisplayable, Self: TagsListTableViewControllerFlowDelegate {
    
    func showListenersForUsername(username: String) {
        let controller = Wireframe.listenersListTableViewController()
        controller.viewModel = ListenersProfilesListViewModel(username: username, showListenButtons: true)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showListeningForUsername(username: String) {
        let controller = Wireframe.listeningListTableViewController()
        controller.viewModel = ListeningProfilesListViewModel(username: username, showListenButtons: true)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showInterestsForUsername(username: String) {
        let controller = Wireframe.interestsListTableViewController()
        controller.viewModel = InterestsTagsListViewModel(username: username, showListenButtons: true)
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}
