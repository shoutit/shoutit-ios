//
//  ProfileDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ProfileDisplayable {
    func showProfile(profile: Profile) -> Void
}

extension FlowController : ProfileDisplayable {
    
    func showProfile(profile: Profile) {
        
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        if case .Logged(let user)? = Account.sharedInstance.loginState where user.id == profile.id {
            controller.viewModel = MyProfileCollectionViewModel()
        } else if case .Some(.Page(let _, let page)) = Account.sharedInstance.loginState where page.id == profile.id {
            controller.viewModel = MyPageCollectionViewModel()
        } else {
            controller.viewModel = UserProfileCollectionViewModel(profile: profile)
        }
        
        navigationController.showViewController(controller, sender: nil)
    }
}
