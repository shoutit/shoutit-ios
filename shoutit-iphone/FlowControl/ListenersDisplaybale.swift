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
}

extension FlowController : ListenersDisplaybale {
    
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
}
