//
//  ListenersDisplaybale.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ListenersDisplaybale {
    func showListenersForUsername(_ username: String) -> Void
    func showListeningForUsername(_ username: String) -> Void
    func showInterestsForUsername(_ username: String) -> Void
}

extension FlowController : ListenersDisplaybale {
    
    func showListenersForUsername(_ username: String) {
        let controller = Wireframe.listenersListTableViewController()
        controller.viewModel = ListenersProfilesListViewModel(username: username, showListenButtons: true)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.show(controller, sender: nil)
    }
    
    func showListeningForUsername(_ username: String) {
        let controller = Wireframe.listeningListTableViewController()
        controller.viewModel = ListeningProfilesListViewModel(username: username, showListenButtons: true)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.show(controller, sender: nil)
    }
    
    func showInterestsForUsername(_ username: String) {
        let controller = Wireframe.interestsListTableViewController()
        controller.viewModel = InterestsTagsListViewModel(username: username, showListenButtons: true)
        controller.flowDelegate = self
        navigationController.show(controller, sender: nil)
    }
}
