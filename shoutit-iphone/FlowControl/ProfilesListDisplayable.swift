//
//  ProfilesListDisplayable.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ProfilesListDisplayable {
    func showListenersForProfile(profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) -> Void
}

extension FlowController: ProfilesListDisplayable {
    
    func showListenersForProfile(profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) {
        let controller = Wireframe.profileListController()
        controller.viewModel = ListenersProfilesListViewModel(username: profile.username, showListenButtons: true)
        controller.eventHandler = eventHandler
        navigationController.showViewController(controller, sender: nil)
    }
}
