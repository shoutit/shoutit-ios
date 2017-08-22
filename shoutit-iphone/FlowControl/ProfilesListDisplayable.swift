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
    func showAddAdminChoiceViewControllerWithProfile(_ profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) -> Void
}

extension FlowController: ProfilesListDisplayable {
    
    func showAddAdminChoiceViewControllerWithProfile(_ profile: Profile, withEventHandler eventHandler: ProfilesListEventHandler) {
        let controller = Wireframe.profileListController()
        controller.title = NSLocalizedString("Add Admin", comment: "New admin choice view header")
        let viewModel = ListenersProfilesListViewModel(username: profile.username, showListenButtons: true)
        viewModel.pager.itemExclusionRule = { (profile) in
            return profile.type == .Page
        }
        
        controller.viewModel = viewModel
        controller.eventHandler = eventHandler
        controller.autoDeselct = true
        controller.dismissAfterSelection = true
        navigationController.show(controller, sender: nil)
    }
}
