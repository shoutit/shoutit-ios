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
    func showAddAdminChoiceViewControllerWithProfile(profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) -> Void
}

extension FlowController: ProfilesListDisplayable {
    
    func showAddAdminChoiceViewControllerWithProfile(profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) {
        let controller = Wireframe.profileListController()
        controller.title = NSLocalizedString("Add Admin", comment: "New admin choice view header")
        controller.viewModel = ListenersProfilesListViewModel(username: profile.username, showListenButtons: true)
        controller.eventHandler = eventHandler
        controller.autoDeselct = true
        controller.dismissAfterSelection = true
        navigationController.showViewController(controller, sender: nil)
    }
}
